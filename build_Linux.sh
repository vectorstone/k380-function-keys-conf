#!/bin/sh
# Build k380 for Linux.
#
# Uses the hidapi-hidraw backend (pkg-config module "hidapi-hidraw") and writes
# ./k380-linux, so the tracked macOS ./k380 binary is never overwritten.
#
# Dependencies (hidapi development files), e.g.:
#   Arch:          sudo pacman -S hidapi
#   Debian/Ubuntu: sudo apt install libhidapi-dev
#   Fedora:        sudo dnf install hidapi-devel
set -eu

cd "$(dirname "$0")"

if ! pkg-config --exists hidapi-hidraw 2>/dev/null; then
	echo "error: hidapi development files not found (pkg-config module hidapi-hidraw)" >&2
	echo "install hidapi and re-run ./build_Linux.sh" >&2
	exit 1
fi

cc -g ${CFLAGS:-} k380_conf.c -o k380-linux \
	$(pkg-config --cflags hidapi-hidraw) \
	$(pkg-config --libs hidapi-hidraw)

echo "built: $(pwd)/k380-linux"
