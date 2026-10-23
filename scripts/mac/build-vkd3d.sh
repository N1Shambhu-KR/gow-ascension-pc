#!/bin/sh
# Build vkd3d (WineHQ's D3D12 on Vulkan, LGPL-2.1) into VKD3D_DIR (.env), for
# the live draw engine's D3D12 on a Mac (ps3kit libs/video/rsx_live_draw_vkd3d.h).
# Then CONFIGURE=1 scripts/mac/build.sh. A few minutes.
#
# Needs: brew install bison molten-vk vulkan-headers spirv-headers
# (macOS's own bison is too old for vkd3d's HLSL grammar).
#
# The release tarball carries its headers already generated from the IDL
# (no widl). make install leaves the DXGI ones out; the swap chain stand-in
# needs IDXGISwapChain3's vtable, so they are copied over from the tarball.
# The vkd3d-*.patch files next to this script are applied first (what the
# engine's HLSL needs that vkd3d's compiler lacks).
set -e
here=$(cd "$(dirname "$0")/../.." && pwd)   # ascension/
. "$here/scripts/unix/env.sh"
[ -n "$VKD3D_DIR" ] || { echo "missing VKD3D_DIR in $here/.env (e.g. VKD3D_DIR=../work/deps/vkd3d)" >&2; exit 1; }
version=2.1
sha256=7510146aff2adfb4ae07ab890701a607e5ff7c66e57100cfc9f630ec92eeda6a
prefix=$(brew --prefix)
for pkg in bison molten-vk vulkan-headers spirv-headers; do
    [ -d "$prefix/opt/$pkg" ] || { echo "missing $pkg (brew install bison molten-vk vulkan-headers spirv-headers)" >&2; exit 1; }
done
logs="$here/build/logs"
mkdir -p "$logs"
log="$logs/vkd3d-build.log"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

echo "vkd3d $version -> $VKD3D_DIR (log: $log)"
curl -fsSL -o "$tmp/vkd3d.tar.xz" "https://dl.winehq.org/vkd3d/source/vkd3d-$version.tar.xz"
echo "$sha256  $tmp/vkd3d.tar.xz" | shasum -a 256 -c - > /dev/null || { echo "vkd3d tarball checksum mismatch" >&2; exit 1; }
tar -xf "$tmp/vkd3d.tar.xz" -C "$tmp"
src="$tmp/vkd3d-$version"
for p in "$here"/scripts/mac/vkd3d-*.patch; do
    [ -f "$p" ] || continue
    patch -d "$src" -p1 -s < "$p" || { echo "patch failed: $p" >&2; exit 1; }
done
mkdir -p "$tmp/build"
start=$(date +%s)
(
    cd "$tmp/build"
    "$src/configure" --prefix="$VKD3D_DIR" --disable-demos --disable-tests \
        BISON="$prefix/opt/bison/bin/bison" CPPFLAGS="-I$prefix/include" LDFLAGS="-L$prefix/lib"
    make -j"$(sysctl -n hw.ncpu)"
    make install
) > "$log" 2>&1 || { tail -n 20 "$log"; exit 1; }
for h in vkd3d_dxgi.h vkd3d_dxgi1_2.h vkd3d_dxgi1_3.h vkd3d_dxgi1_4.h vkd3d_dxgitype.h; do
    cp "$src/include/$h" "$VKD3D_DIR/include/vkd3d/"
done
secs=$(( $(date +%s) - start ))
printf 'vkd3d OK in %d:%02d\n' $((secs / 60)) $((secs % 60))
