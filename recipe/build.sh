#!/bin/bash

set -ex

# remove outdated vendored headers
rm -rf $SRC_DIR/python/triton/third_party

export JSON_SYSPATH=$PREFIX
export LLVM_SYSPATH=$PREFIX
export PYBIND11_SYSPATH=$SP_DIR/pybind11

# these don't seem to be actually used, but they prevent downloads
export TRITON_OFFLINE_BUILD=1

export MAX_JOBS=$CPU_COUNT

# LLVM currently does not provide a way to override the tablegen executables,
# effectively forcing the value of MLIR_TABLEGEN_EXE obtained
# from MLIRConfig.cmake, that corresponds to PREFIX. Overwrite it to force
# BUILD_PREFIX.
sed -i -e '/find_package(MLIR/aset(MLIR_TABLEGEN_EXE "$ENV{BUILD_PREFIX}/bin/mlir-tblgen")' CMakeLists.txt

cd python
$PYTHON -m pip install . -vv
