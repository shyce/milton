#!/bin/bash

set -euo pipefail

MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$MYDIR"

BUILD_TYPE="${BUILD_TYPE:-Debug}"
ARCHS="${MILTON_MAC_ARCHS:-arm64;x86_64}"
CMAKE_POLICY_FLAG="${CMAKE_POLICY_FLAG:-3.5}"

echo "Building SDL3 for macOS (${ARCHS}, ${BUILD_TYPE})..."
pushd third_party/SDL3-3.4.4 >/dev/null
    mkdir -p build/macos-universal
    pushd build/macos-universal >/dev/null
        cmake \
            -G "Unix Makefiles" \
            -D SDL_SHARED:BOOL=OFF \
            -D SDL_STATIC:BOOL=ON \
            -D SDL_STATIC_PIC:BOOL=ON \
            -D SDL_TESTS:BOOL=OFF \
            -D SDL_EXAMPLES:BOOL=OFF \
            -D SDL_INSTALL_TESTS:BOOL=OFF \
            -D CMAKE_BUILD_TYPE="${BUILD_TYPE}" \
            -D CMAKE_POLICY_VERSION_MINIMUM="${CMAKE_POLICY_FLAG}" \
            -D CMAKE_OSX_ARCHITECTURES="${ARCHS}" \
            -D CMAKE_INSTALL_PREFIX="../macos-universal" \
            ../..
        cmake --build . --config "${BUILD_TYPE}" -j
        cmake --install . --config "${BUILD_TYPE}"
    popd >/dev/null
popd >/dev/null

echo "Building Milton app bundle..."
cmake \
    -S . \
    -B build/macrelease \
    -D CMAKE_BUILD_TYPE="${BUILD_TYPE}" \
    -D CMAKE_POLICY_VERSION_MINIMUM="${CMAKE_POLICY_FLAG}" \
    -D CMAKE_OSX_ARCHITECTURES="${ARCHS}" \
    "$@"
cmake --build build/macrelease --config "${BUILD_TYPE}" -j

echo "Build complete."
echo "App bundle: ${MYDIR}/build/macrelease/Milton.app"
echo "App binary: ${MYDIR}/build/macrelease/Milton.app/Contents/MacOS/Milton"
