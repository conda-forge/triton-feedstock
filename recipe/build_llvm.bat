@echo on

set "SRC=%SRC_DIR:\=/%"

cmake -G Ninja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DLLVM_BUILD_UTILS=OFF ^
    -DLLVM_BUILD_TOOLS=OFF ^
    -DLLD_BUILD_TOOLS=OFF ^
    -DLLVM_BUILD_TELEMETRY=OFF ^
    -DLLVM_ENABLE_PROJECTS="" ^
    -DLLVM_TARGETS_TO_BUILD="AMDGPU" ^
    -DLLVM_ENABLE_TERMINFO=OFF ^
    -DLLVM_ENABLE_ZLIB=OFF ^
    -DLLVM_ENABLE_ZSTD=OFF ^
    -DLLVM_ENABLE_LIBXML2=OFF ^
    -DLLVM_ENABLE_DIA_SDK=OFF ^
    -DLLVM_INCLUDE_TESTS=OFF ^
    -DLLVM_INCLUDE_BENCHMARKS=OFF ^
    -DLLVM_INCLUDE_EXAMPLES=OFF ^
    -Bllvm-project-amd/build -Sllvm-project-amd/llvm
if %ERRORLEVEL% neq 0 exit 1
cmake --build llvm-project-amd/build -j %CPU_COUNT%
if %ERRORLEVEL% neq 0 exit 1

cmake -G Ninja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DLLVM_DIR=%SRC%/llvm-project-amd/build/lib/cmake/llvm ^
    -DTRITON_AMD_LLVM_REVISION=%AMD_LLVM_COMMIT% ^
    -DCMAKE_INSTALL_PREFIX=%SRC%/third_party/amd/backend ^
    -Bamd-codegen-build -Sthird_party/amd/backend/codegen
if %ERRORLEVEL% neq 0 exit 1
cmake --build amd-codegen-build -j %CPU_COUNT%
if %ERRORLEVEL% neq 0 exit 1
cmake --install amd-codegen-build
if %ERRORLEVEL% neq 0 exit 1

rmdir /s /q llvm-project-amd\build

cmake -G Ninja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DLLVM_BUILD_UTILS=ON ^
    -DLLVM_BUILD_TOOLS=OFF ^
    -DLLD_BUILD_TOOLS=OFF ^
    -DLLVM_BUILD_TELEMETRY=OFF ^
    -DLLVM_ENABLE_PROJECTS="clang;mlir;lld" ^
    -DLLVM_TARGETS_TO_BUILD="host;NVPTX;AMDGPU" ^
    -DLLVM_ENABLE_TERMINFO=OFF ^
    -DLLVM_ENABLE_ZLIB=OFF ^
    -DLLVM_ENABLE_ZSTD=OFF ^
    -DLLVM_ENABLE_LIBXML2=OFF ^
    -DLLVM_ENABLE_DIA_SDK=OFF ^
    -DLLVM_INCLUDE_TESTS=OFF ^
    -DLLVM_INCLUDE_BENCHMARKS=OFF ^
    -DLLVM_INCLUDE_EXAMPLES=OFF ^
    -DMLIR_INCLUDE_TESTS=OFF ^
    -Bllvm-project/build -Sllvm-project/llvm
if %ERRORLEVEL% neq 0 exit 1
cmake --build llvm-project/build -j %CPU_COUNT%
if %ERRORLEVEL% neq 0 exit 1

del /s /q llvm-project\build\*.obj > nul
