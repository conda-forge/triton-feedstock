@echo on

rmdir /s /q "%SRC_DIR%\python\triton\third_party"

set TRITON_OFFLINE_BUILD=1
set TRITON_BUILD_PROTON=OFF

set "CMAKE_PREFIX_PATH=%LIBRARY_PREFIX%"

set "SRC=%SRC_DIR:\=/%"
set "LIB_PREFIX=%LIBRARY_PREFIX:\=/%"

set "JSON_SYSPATH=%LIB_PREFIX%"

set "TRITON_PTXAS_PATH=%LIB_PREFIX%/bin/ptxas.exe"
set "TRITON_CUOBJDUMP_PATH=%LIB_PREFIX%/bin/cuobjdump.exe"
set "TRITON_NVDISASM_PATH=%LIB_PREFIX%/bin/nvdisasm.exe"
set "TRITON_CUDACRT_PATH=%LIB_PREFIX%"
set "TRITON_CUDART_PATH=%LIB_PREFIX%"
set "TRITON_CUPTI_INCLUDE_PATH=%LIB_PREFIX%/include"
set "TRITON_CUPTI_LIB_PATH=%LIB_PREFIX%/lib"

set MAX_JOBS=%CPU_COUNT%

rem the build does not run C++ unittests, and they implicitly fetch gtest
rem no easy way of passing this, not really worth a whole patch
sed -i -e "/TRITON_BUILD_UT/s:\bON:OFF:" CMakeLists.txt
if %ERRORLEVEL% neq 0 exit 1

set "LLVM_SYSPATH=%SRC%/llvm-project/build"
set "LLVM_INCLUDE_DIRS=%LLVM_SYSPATH%/include"
set "LLVM_LIBRARY_DIR=%LLVM_SYSPATH%/lib"
set "TRITON_AMD_CODEGEN_PATH=%SRC%/third_party/amd/backend"

set "CXXFLAGS=%CXXFLAGS% /bigobj /Zc:preprocessor /permissive- /utf-8"

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if %ERRORLEVEL% neq 0 exit 1
