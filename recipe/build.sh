#!/bin/bash

set -ex

# remove outdated vendored headers
rm -rf $SRC_DIR/python/triton/third_party

# disable downloading dependencies entirely
export TRITON_OFFLINE_BUILD=1

export JSON_SYSPATH=$PREFIX
export PYBIND11_SYSPATH=$SP_DIR/pybind11

# only some of them are actually used currently, but set all just in case
export TRITON_PTXAS_PATH=$PREFIX/bin/ptxas
export TRITON_CUOBJDUMP_PATH=$PREFIX/bin/cuobjdump
export TRITON_NVDISASM_PATH=$PREFIX/bin/nvdisasm
export TRITON_CUDACRT_PATH=$PREFIX
export TRITON_CUDART_PATH=$PREFIX
export TRITON_CUPTI_INCLUDE_PATH=$PREFIX/include
export TRITON_CUPTI_LIB_PATH=$PREFIX/lib

export MAX_JOBS=$CPU_COUNT

# the build does not run C++ unittests, and they implicitly fetch gtest
# no easy way of passing this, not really worth a whole patch
sed -i -e '/TRITON_BUILD_UT/s:\bON:OFF:' CMakeLists.txt

# don't emit debug info for triton's own objects: it's stripped from the
# final library anyway (-Wl,-s below), so generating it just wastes build
# disk and link memory. LLVM is already built without -g (Release).
sed -i -e '/FLAGS_TRITONRELBUILDWITHASSERTS/s: -g::' CMakeLists.txt

export LLVM_SYSPATH=$PWD/llvm-project/build
export LLVM_INCLUDE_DIRS=$LLVM_SYSPATH/include
export LLVM_LIBRARY_DIR=$LLVM_SYSPATH/lib

# Strip symbols at link time to shrink the package: statically-linked LLVM
# adds a large symbol table to libtriton.so, and rattler-build does not
# strip in post-processing. Append to LDFLAGS to keep conda's flags intact.
export LDFLAGS="${LDFLAGS} -Wl,-s"

$PYTHON -m pip install . -vv
