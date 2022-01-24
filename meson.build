# Bifrost wrapper file
project('xcorr_lite', 'cpp', 'cuda', version: '1.0.0',
         default_options : ['cpp_std=c++11'])
plugin_name = 'xcorr_lite'
cc = meson.get_compiler('cpp')

# CUDA setup
cuda = import('unstable-cuda')
cuda_dep = dependency('cuda', version : '>=11', modules : ['cudart', 'nvrtc'])

# Dependency: bifrost
bf_dep = dependency('bifrost')
bifrost_src_path = '/group/director2183/dancpr/src/bifrost/src/'

bf_include = include_directories(
    bifrost_src_path, 
    bifrost_src_path / 'bifrost', 
    bifrost_src_path / 'cuda'
    )


# CUDA flags
#nvflags = cuda.nvcc_arch_flags('11.1', 'Volta')
#message(cuda.min_driver_version('11.1'))

# Generate python wrapper from .h file
builddir = meson.project_build_root()
r = run_command('./generate_wrapper.py', 'src' / plugin_name, '-o', builddir, check: true)
message(r.stdout().strip())

# Generate shared object from .cu file
lib = library(plugin_name, 'src' / plugin_name + '.cu',  
              version : '1.0.0', soversion : '0', 
              dependencies: [bf_dep, cuda_dep], include_directories: bf_include)


