#!/bin/bash

set -ex

# remove outdated vendored headers
rm -rf $SRC_DIR/python/triton/third_party

export TRITON_OFFLINE_BUILD=1

export JSON_SYSPATH=$PREFIX
export PYBIND11_SYSPATH=$SP_DIR/pybind11

# these don't seem to be actually used, but they prevent downloads
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

# build LLVM first
cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_BUILD_UTILS=OFF \
    -DLLVM_BUILD_TOOLS=OFF \
    -DLLD_BUILD_TOOLS=OFF \
    -DLLVM_BUILD_TELEMETRY=OFF \
    -DLLVM_ENABLE_PROJECTS="mlir;lld" \
    -DLLVM_TARGETS_TO_BUILD="host;NVPTX;AMDGPU" \
    -DLLVM_ENABLE_TERMINFO=OFF \
    -Bllvm-project/build \
    llvm-project/llvm
cmake --build llvm-project/build -j "${MAX_JOBS}"

export LLVM_SYSPATH=$PWD/llvm-project/build
export LLVM_INCLUDE_DIRS=$LLVM_SYSPATH/include
export LLVM_LIBRARY_DIR=$LLVM_SYSPATH/lib

cd python
$PYTHON -m pip install . -vv
