#include <bifrost/xcorr_lite.h>
#include <bifrost/array.h>
#include <bifrost/common.h>
#include <bifrost/ring.h>
#include "cuda.hpp"
#include <utils.hpp>
#include <stdlib.h>
#include <stdio.h>
#include <iostream>


#define DCP_DEBUG

extern "C" {

    __forceinline__ __device__
    void dp4a(int &c, const int &a, const int &b) {
        #if __CUDA_ARCH__ >= 610
          asm("dp4a.s32.s32 %0, %1, %2, %3;" : "+r"(c) : "r"(a), "r"(b), "r"(c)); 
        #else
          char4 &a4 = *((char4*)&a);
          char4 &b4 = *((char4*)&b);
          c += a4.x*b4.x;
          c += a4.y*b4.y;
          c += a4.z*b4.z;
          c += a4.w*b4.w;
        #endif
        }

    /*
      cmult_dp4a -- Do complex conjugate multiply accumulate <A*Conj(B)>
      Using two dp4a instructions. Takes 8-bit complex data 
      packed as a single 32-bit int [8R8I 8R8I]. 
  
      For two complex numbers:
          ab* = (ar + i*ai)(br + i*bi)
          re(ab*) = ar*br + ai*bi
          im(ab*) = ai*br - ar*bi
      So use two dp4a to compute:
          [a0r a0i a1r a1i].[b0r b0i b1r b1i]   = Re(<ab*>)
          [a0r a0i a1r a1i].[-b0i b0r -b1i b1r] = Im(<ab*>)
      Where angled brackets denote time averaging (over 2x samples)
    */
    __forceinline__ __device__
    void cmult_dp4a(int &res_re, int &res_im, int &A, int &B) {
        // Unpack 32-bit int into 8-bit
        int8_t Bmod[4];
        int8_t *b8 = (int8_t *)&B;      
    
        // Transpose for bmod 
        Bmod[0] = -b8[1];
        Bmod[1] = b8[0];
        Bmod[2] = -b8[3];
        Bmod[3] = b8[2]; 
    
        //int8_t *a8 = (int8_t *)&A;
        //printf("A %d %d %d %d | B %d %d %d %d\\n", a8[0], a8[1], a8[2], a8[3], b8[0], b8[1], b8[2], b8[3]);
    
        // Pack 8-bit to 32-bit
        int &Bmodp = *((int *)&Bmod); 
    
        // Run complex multiply
        dp4a(res_re, A, B);
        dp4a(res_im, A, Bmodp);
        }


    // Data array should be (heap H, frequency F, antenna N, fine_time T)
    __global__ void xcorrDp4aKernel
        (int *data, float *xcorr, int H, int N, int T, int reset)
        {
        // Setup thread indexes
        const int x = blockIdx.x * blockDim.x + threadIdx.x;
        const int y = blockIdx.y * blockDim.y + threadIdx.y;
        // note that F(nchan) is gridDim.z
        
        // Only run if antenna IDs X and Y are < N_antenna (N)
        if (x < N && y < N) {

            // Loop over heap (H)
            for (int h = 0; h < H; h++) {

                int chan_offset_out = blockIdx.z * N * N * 2;
                int ant_offset      = T / 2;  //x2 for complex, but /4 for packed
                int heap_offset_out = h * gridDim.z * N * N * 2;

                //                        heap_offset              +  chan_offset
                int heapchan_offset_in = (h * gridDim.z * N * T/2) + (blockIdx.z * N * T/2);
                
                int xy_real = 0;
                int xy_imag = 0;
                const int idx = 2*y + N*2*x + chan_offset_out + heap_offset_out; // Compute index for output array
                
                // Note -- using dp4a must be careful of bit growth.
                // output of each 8-bit dot product is 16 bits
                // Adding 4x 16-bit numbers = 18-bit number
                // accumulator is only 32 bits, so using 18 of 32 bits.
                // Max 14 bits of growth = 2^14 = 4096 integrations
                
                const int ia  = heapchan_offset_in + ant_offset*x;
                const int ib  = heapchan_offset_in + ant_offset*y;
               
                for (int t = 0; t < T/2; t++) {         
                    //printf("idx %d | x%d.y%d | A %dx%d\\n", idx, x, y, ia + t, ib + t);
                    //cmult_dp4a(xcorr[idx], xcorr[idx+1], data[ia + t], data[ib + t]);
                    cmult_dp4a(xy_real, xy_imag, data[ia + t], data[ib + t]);
                }
            
                // Copy xy* result to device mem
                if (reset != 0) {
                    xcorr[idx]   = (float) xy_real;
                    xcorr[idx+1] = (float) xy_imag;
                } else {
                    xcorr[idx]   += (float) xy_real;
                    xcorr[idx+1] += (float) xy_imag;
                }
              } // Loop over heap (H)
           } // if x < N and y < N
        }
        
    void launch_xcorr_lite(int *data, float *xcorr, int H, int F, int N, int T, int reset) {
        dim3 block, grid;
        int GS = 1; // Grid size for antenna
        int NB = N;     // Block size for antenna
        // Set grid size for N > 32
        if(N > 32) {
            GS = ceil(float(N) / 32);
            NB = 32;
        }

        grid.x = GS;
        grid.y = GS;
        grid.z = F;
        
        block.x = NB;
        block.y = NB;
        block.z = 1;

        cudaStream_t g_cuda_stream = 0;

#ifdef DCP_DEBUG
        //printf("N: %d SHM %d\n", N, shm_bytes);
  printf("Debug: <<<B: (%d, %d, %d) G: (%d, %d, %d)  >>>\n", block.x,
         block.y, block.z, grid.x, grid.y, grid.z);
#endif
         int shm = 0;
        xcorrDp4aKernel<<< grid, block, shm, g_cuda_stream >>>(data, xcorr, H, N, T, reset);
    }
        


    BFstatus XcorrLite(BFarray *bf_data, BFarray *bf_xcorr, int reset)
    {
        
        int* data = (int *)bf_data->data;
        float* xcorr = (float *)bf_xcorr->data;

        int H = bf_data->shape[0]; // Heap (slow time axis)
        int F = bf_data->shape[1]; // Frequency
        int N = bf_data->shape[2]; // Antenna
        int T = bf_data->shape[3]; // Fine time
        
        //printf("ispan dims F: %d N: %d T: %d\n", F, N, T);
        launch_xcorr_lite(data, xcorr, H, F, N, T, reset);
        
        BF_CHECK_CUDA(cudaGetLastError(), BF_STATUS_DEVICE_ERROR);

        return BF_STATUS_SUCCESS;
    }

}