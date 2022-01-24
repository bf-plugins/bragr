export BF_VER=0.0.3
source ~/pacer_env.sh

module load bifrost/${BF_VER}
export PKG_CONFIG_PATH=/group/director2183/dancpr/software/centos7.6/apps/cascadelake/gcc/8.3.0/bifrost/${BF_VER}/lib/pkgconfig:$PKG_CONFIG_PATH
export PATH=/group/director2183/dancpr/src/:/group/director2183/dancpr/src/bifrost/src:$PATH
export PATH=/group/director2183/dancpr/.local/bin/:$PATH
export PYTHONPATH=/group/director2183/dancpr/.local/lib/python3.6/site-packages:$PYTHONPATH
export LD_LIBRARY_PATH=`pwd`/build:$LD_LIBRARY_PATH
