#!/bin/bash

set -ex

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

# build LLVM first
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
    cmake --build llvm-project/build-native -j "${MAX_JOBS}" \
        -t "${NATIVE_EXECUTABLES[@]}"

    NATIVE_BIN=$PWD/llvm-project/build-native/bin
    CMAKE_HOST_ARGS+=(
        -DCMAKE_CROSSCOMPILING=ON
        -DLLVM_NATIVE_TOOL_DIR=$PWD/llvm-project/build-native/bin
        #-DLLVM_TABLEGEN=$NATIVE_BIN/llvm-tblgen
        #-DMLIR_TABLEGEN=$NATIVE_BIN/mlir-tblgen
        #-DMLIR_LINALG_ODS_YAML_GEN
    )
fi

cmake -G Ninja "${CMAKE_HOST_ARGS[@]}" \
    -Bllvm-project/build -Sllvm-project/llvm
cmake --build llvm-project/build -j "${MAX_JOBS}"
