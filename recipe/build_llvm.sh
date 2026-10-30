#!/bin/bash

set -ex

# 1. Build LLVM for AMDGPU codegen

CMAKE_HOST_ARGS=(
    -DCMAKE_BUILD_TYPE=Release
    -DLLVM_BUILD_UTILS=OFF
    -DLLVM_BUILD_TOOLS=OFF
    -DLLD_BUILD_TOOLS=OFF
    -DLLVM_BUILD_TELEMETRY=OFF
    -DLLVM_ENABLE_PROJECTS=""
    -DLLVM_TARGETS_TO_BUILD="AMDGPU"
    -DLLVM_ENABLE_TERMINFO=OFF
    -DLLVM_INCLUDE_TESTS=OFF
    ${TRITON_BUILD_WITH_CCACHE:+-DLLVM_CCACHE_BUILD=ON}
)

if [[ ${HOST} != ${BUILD} ]]; then
    CMAKE_BUILD_ARGS=(
        -DCMAKE_C_COMPILER="${CC_FOR_BUILD}"
        -DCMAKE_CXX_COMPILER="${CXX_FOR_BUILD}"
        -DCMAKE_BUILD_TYPE=Release
        -DLLVM_ENABLE_ZSTD=OFF
        -DLLVM_ENABLE_LIBXML2=OFF
        -DLLVM_ENABLE_ZLIB=OFF
        ${TRITON_BUILD_WITH_CCACHE:+-DLLVM_CCACHE_BUILD=ON}
    )
    NATIVE_EXECUTABLES=(
        llvm-tblgen
    )

    cmake -G Ninja "${CMAKE_BUILD_ARGS[@]}" \
        -Bllvm-project-amd/build-native -Sllvm-project-amd/llvm
    cmake --build llvm-project-amd/build-native -j "${CPU_COUNT}" \
        -t "${NATIVE_EXECUTABLES[@]}"

    NATIVE_BIN=${PWD}/llvm-project-amd/build-native/bin
    CMAKE_HOST_ARGS+=(
        -DCMAKE_CROSSCOMPILING=ON
        -DLLVM_NATIVE_TOOL_DIR=${PWD}/llvm-project-amd/build-native/bin
    )
fi

cmake -G Ninja "${CMAKE_HOST_ARGS[@]}" \
    -Bllvm-project-amd/build -Sllvm-project-amd/llvm
cmake --build llvm-project-amd/build -j "${CPU_COUNT}"

# 2. Build standalone AMD codegen

CMAKE_ARGS=(
    -DCMAKE_BUILD_TYPE=Release
    -DLLVM_DIR=${PWD}/llvm-project-amd/build/lib/cmake/llvm
    -DTRITON_AMD_LLVM_REVISION=${AMD_LLVM_COMMIT}
    # the library gets installed into lib/ where it is expected
    -DCMAKE_INSTALL_PREFIX=${PWD}/third_party/amd/backend
)

cmake -G Ninja "${CMAKE_ARGS[@]}" \
    -Bamd-codegen-build -Sthird_party/amd/backend/codegen
cmake --build amd-codegen-build -j "${CPU_COUNT}"
cmake --install amd-codegen-build -j "${CPU_COUNT}"

# 3. Build LLVM for Triton

CMAKE_HOST_ARGS=(
    -DCMAKE_BUILD_TYPE=Release
    -DLLVM_BUILD_UTILS=ON
    -DLLVM_BUILD_TOOLS=OFF
    -DLLD_BUILD_TOOLS=OFF
    -DLLVM_BUILD_TELEMETRY=OFF
    -DLLVM_ENABLE_PROJECTS="clang;mlir;lld"
    -DLLVM_TARGETS_TO_BUILD="host;NVPTX;AMDGPU"
    -DLLVM_ENABLE_TERMINFO=OFF
    -DLLVM_INCLUDE_TESTS=OFF
    -DMLIR_INCLUDE_TESTS=OFF
    ${TRITON_BUILD_WITH_CCACHE:+-DLLVM_CCACHE_BUILD=ON}
)

if [[ ${HOST} != ${BUILD} ]]; then
    CMAKE_BUILD_ARGS=(
        -DCMAKE_C_COMPILER="${CC_FOR_BUILD}"
        -DCMAKE_CXX_COMPILER="${CXX_FOR_BUILD}"
        -DCMAKE_BUILD_TYPE=Release
        -DLLVM_ENABLE_ZSTD=OFF
        -DLLVM_ENABLE_LIBXML2=OFF
        -DLLVM_ENABLE_ZLIB=OFF
        -DLLVM_ENABLE_PROJECTS="mlir"
        ${TRITON_BUILD_WITH_CCACHE:+-DLLVM_CCACHE_BUILD=ON}
    )
    NATIVE_EXECUTABLES=(
        llvm-tblgen
        mlir-tblgen
        mlir-linalg-ods-yaml-gen
        mlir-src-sharder
        mlir-pdll
    )

    cmake -G Ninja "${CMAKE_BUILD_ARGS[@]}" \
        -Bllvm-project/build-native -Sllvm-project/llvm
    cmake --build llvm-project/build-native -j "${CPU_COUNT}" \
        -t "${NATIVE_EXECUTABLES[@]}"

    NATIVE_BIN=${PWD}/llvm-project/build-native/bin
    CMAKE_HOST_ARGS+=(
        -DCMAKE_CROSSCOMPILING=ON
        -DLLVM_NATIVE_TOOL_DIR=${PWD}/llvm-project/build-native/bin
    )
fi

cmake -G Ninja "${CMAKE_HOST_ARGS[@]}" \
    -Bllvm-project/build -Sllvm-project/llvm
cmake --build llvm-project/build -j "${CPU_COUNT}"
