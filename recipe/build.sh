#!/bin/bash

set -ex

# need to communicate with setup.py
export LLVM_SYSPATH="$PREFIX"
export PYBIND11_SYSPATH="$PREFIX"

# remove outdated vendored headers
rm -rf $SRC_DIR/python/triton/third_party

cd python
$PYTHON -m pip install . -vv
