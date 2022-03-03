#include <bifrost/xcorr_lite.h>
#include <bifrost/array.h>
#include <bifrost/common.h>
#include <bifrost/ring.h>
#include "cuda.hpp"
#include <utils.hpp>
#include <stdlib.h>
#include <stdio.h>
#include <iostream>

#include "{{cookiecutter.__snake_name}}.h"
thread_local cudaStream_t g_cuda_stream = cudaStreamPerThread;

/*!
  \class {{cookiecutter.__class_name}}
  \brief Plugger class for {{cookiecutter.__camel_name}}
*/
class {{cookiecutter.__class_name}} {
private:
    // Parameters passed during init() may be stored here, use _n_param 
    int _n_param1;
    cudaStream_t _stream;
    
public:
    {{cookiecutter.__class_name}}() : _stream(g_cuda_stream) {}
    ~{{cookiecutter.__class_name}}() {
        cudaDeviceSynchronize();
    }
    
    inline int n_param1() const { return _n_param1; }

    // Initialize your plugin here
    void init(int n_param1) {
        _n_param1 = n_param1; // This stores parameter as a private _n_params
       
        // Zero out any existing state
        this->reset_state();
    }

    // Needed to set CUDA stream for asynchronous launching
    void set_stream(cudaStream_t stream) {
        cudaDeviceSynchronize();
        _stream = stream;
    }

    // Do any zeroing / memset stuff here
    void reset_state() {
        
    }

    // execute your plugin
    void exec(BFarray const* in, BFarray* out) {
        
        // Check for errors
        BF_CHECK_CUDA_EXCEPTION(cudaGetLastError(), BF_STATUS_INTERNAL_ERROR);  
        }
};

// Used by bifrost python wrapper at instantiation
BFstatus {{cookiecutter.__camel_name}}Create(bfplugin* plan_ptr) {
    BF_ASSERT(plan_ptr, BF_STATUS_INVALID_POINTER);
    BF_TRY_RETURN_ELSE(*plan_ptr = new {{cookiecutter.__class_name}}(),
                       *plan_ptr = 0);
}

// Initialisation for plugin 
BFstatus {{cookiecutter.__camel_name}}Init(bfplugin plan, int n_param1) {
    BF_ASSERT(plan, BF_STATUS_INVALID_HANDLE);
    BF_TRY_RETURN(plan->init(n_param1));
}

// Assign to CUDA stream
BFstatus {{cookiecutter.__camel_name}}SetStream(bfplugin plan, void const* stream) {
        BF_ASSERT(plan, BF_STATUS_INVALID_HANDLE);
        BF_ASSERT(stream, BF_STATUS_INVALID_POINTER);
        BF_TRY_RETURN(plan->set_stream(*(cudaStream_t*)stream));
}

// Reset state of any internal memory 
BFstatus {{cookiecutter.__camel_name}}ResetState(bfplugin plan) {
        BF_ASSERT(plan, BF_STATUS_INVALID_HANDLE);
        BF_TRY_RETURN(plan->reset_state());
}

// Main method to execute data processing tasks
BFstatus {{cookiecutter.__camel_name}}Execute(bfplugin plan,
                     BFarray const* in,
                     BFarray*       out) {
    BF_ASSERT(plan, BF_STATUS_INVALID_POINTER);
    BF_ASSERT(in,   BF_STATUS_INVALID_POINTER);
  	BF_ASSERT(out,  BF_STATUS_INVALID_POINTER);
    
    BF_ASSERT(space_accessible_from(in->space, BF_SPACE_CUDA),
              BF_STATUS_UNSUPPORTED_SPACE);
    BF_ASSERT(space_accessible_from(out->space, BF_SPACE_CUDA),
              BF_STATUS_UNSUPPORTED_SPACE);
    
    BF_TRY_RETURN(plan->exec(in, out));
}

// Called by python wrapper at deletion time
BFstatus {{cookiecutter.__camel_name}}Destroy(bfplugin plan) {
    BF_ASSERT(plan, BF_STATUS_INVALID_HANDLE);
    delete plan;
    return BF_STATUS_SUCCESS;
}