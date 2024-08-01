#!/bin/bash

set -ex

# Currently we leave CUDA vendored-in, see
# patches section for reasoning.
# Uncomment this if we want to change this.
# remove outdated vendored headers
#rm -rf $SRC_DIR/python/triton/third_party

# To find e.g. the right libstdc++
export LD_LIBRARY_PATH=${PREFIX}/lib:$LD_LIBRARY_PATH

cd python
$PYTHON -m pip install . -vv --no-deps --no-build-isolation
