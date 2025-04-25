#!/bin/bash

set -ex

# remove outdated vendored headers
rm -rf $SRC_DIR/python/triton/third_party

export TRITON_OFFLINE_BUILD=1

export JSON_SYSPATH=$PREFIX
export LLVM_SYSPATH=$PREFIX
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

# LLVM currently does not provide a way to override the tablegen executables,
# effectively forcing the value of MLIR_TABLEGEN_EXE obtained
# from MLIRConfig.cmake, that corresponds to PREFIX. Overwrite it to force
# BUILD_PREFIX.
sed -i -e '/find_package(MLIR/aset(MLIR_TABLEGEN_EXE "$ENV{BUILD_PREFIX}/bin/mlir-tblgen")' CMakeLists.txt

cd python
$PYTHON -m pip install . -vv
