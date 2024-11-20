#!/bin/bash

set -ex

# remove outdated vendored headers
rm -rf $SRC_DIR/python/triton/third_party

export JSON_SYSPATH=$PREFIX
# enable LLVM_SYSPATH when we can unvendor it (i.e. have a version match)
# export LLVM_SYSPATH=$PREFIX
export PYBIND11_SYSPATH=$SP_DIR/pybind11

cd python
$PYTHON -m pip install . -vv
