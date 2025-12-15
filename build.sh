#!/usr/bin/env bash
set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/bin"
BUILD_FLAGS="-trimpath -tags netgo"
LDFLAGS="-s -w"

# Architectures
PLATFORMS="darwin/amd64 darwin/arm64 windows/amd64 linux/amd64"

# Create output directory
mkdir -p "${OUTPUT_DIR}"

echo "Building Monetarium binaries..."
echo "Output directory: ${OUTPUT_DIR}"
echo ""

# Build function
build_binary() {
    local name=$1
    local src_dir=$2

    for platform in $PLATFORMS; do
        GOOS="${platform%/*}"
        GOARCH="${platform#*/}"

        # Add .exe extension for Windows
        ext=""
        if [ "$GOOS" = "windows" ]; then
            ext=".exe"
        fi

        output="${OUTPUT_DIR}/${name}-${GOOS}-${GOARCH}${ext}"

        echo "Building ${name}-${GOOS}-${GOARCH}..."

        (
            cd "${SCRIPT_DIR}/${src_dir}"
            CGO_ENABLED=0 GOOS="$GOOS" GOARCH="$GOARCH" \
                go build ${BUILD_FLAGS} -ldflags="${LDFLAGS}" -o "${output}" .
        )
    done
}

# Build all binaries
build_binary "node" "dcrd"
build_binary "ctl" "dcrctl"
build_binary "wallet" "dcrwallet"

echo ""
echo "Build complete! Binaries:"
ls -lh "${OUTPUT_DIR}"
