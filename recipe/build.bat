rem remove outdated vendored headers
del /s %SRC_DIR%/python/triton/third_party

set JSON_SYSPATH=%PREFIX%
set LLVM_SYSPATH=%PREFIX%
set PYBIND11_SYSPATH=%SP_DIR%/pybind11

rem these don't seem to be actually used, but they prevent downloads
set TRITON_PTXAS_PATH=%PREFIX%/bin/ptxas
set TRITON_CUOBJDUMP_PATH=%PREFIX%/bin/cuobjdump
set TRITON_NVDISASM_PATH=%PREFIX%/bin/nvdisasm
set TRITON_CUDACRT_PATH=%PREFIX%
set TRITON_CUDART_PATH=%PREFIX%
set TRITON_CUPTI_PATH=%PREFIX%

set MAX_JOBS=%CPU_COUNT%

rem the build does not run C++ unittests, and they implicitly fetch gtest
rem no easy way of passing this, not really worth a whole patch
sed -i -e '/TRITON_BUILD_UT/s:\bON:OFF:' CMakeLists.txt

%PYTHON% -m pip install . -vv
