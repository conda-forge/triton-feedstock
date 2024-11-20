#!/bin/bash

set -ex

# remove outdated vendored headers
rm -rf $SRC_DIR/python/triton/third_party

export JSON_SYSPATH=$PREFIX
export LLVM_SYSPATH=$PREFIX
export PYBIND11_SYSPATH=$SP_DIR/pybind11

export MAX_JOBS=$CPU_COUNT

cd python
$PYTHON -m pip install . -vv
