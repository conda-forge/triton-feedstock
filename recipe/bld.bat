rem remove outdated vendored headers
del /s %SRC_DIR%/python/triton/third_party

set JSON_SYSPATH=%PREFIX%
set LLVM_SYSPATH=%PREFIX%
set PYBIND11_SYSPATH=%SP_DIR%/pybind11

rem these don't seem to be actually used, but they prevent downloads
set TRITON_OFFLINE_BUILD=1

set MAX_JOBS=%CPU_COUNT%

cd python
%PYTHON% -m pip install . -vv
