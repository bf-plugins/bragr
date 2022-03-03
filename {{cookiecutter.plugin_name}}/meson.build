# Bifrost wrapper file
project('{{cookiecutter.__snake_name}}', 'cpp', 'cuda', version: '{{cookiecutter.plugin_version}}',
         default_options : ['cpp_std=c++11'])
plugin_name = '{{cookiecutter.__snake_name}}'
cc = meson.get_compiler('cpp')

# CUDA setup
cuda = import('unstable-cuda')
cuda_dep = dependency('cuda', version : '>=11', modules : ['cudart', 'nvrtc'])

# Dependency: bifrost
bf_dep = dependency('bifrost')
bifrost_src_path = '{{cookiecutter.bifrost_source_path}}'

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
message('Generating ctypes wrapper from {{cookiecutter.__snake_name}}.h')
r = run_command('./generate_wrapper.py', 'src' / plugin_name, '-o', builddir, check: true)
message(r.stdout().strip())
r = run_command('./wrap_bifrost_plugin.py', builddir / plugin_name+'_generated.py', 
                '-o', builddir, check: true)
message(r.stdout().strip())

# Generate shared object from .cu file
lib = library(plugin_name, 'src' / plugin_name + '.cu',  
              version : '{{cookiecutter.plugin_version}}', soversion : '0', 
              dependencies: [bf_dep, cuda_dep], include_directories: bf_include)


