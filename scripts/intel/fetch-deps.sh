#!/usr/bin/env bash
set -euo pipefail
ROOT="${ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
BLENDER_SRC="${BLENDER_SRC:-$ROOT/upstream}"
DEPS_INSTALL_DIR="${DEPS_INSTALL_DIR:-$ROOT/lib-macos-x64}"
REPO="${REPO:-lastowl/intel-blender-5}"
versions="$BLENDER_SRC/build_files/build_environment/cmake/versions.cmake"
[[ -f "$versions" ]] || { echo "error: cannot find $versions" >&2; exit 1; }
tag="deps-x64-$(shasum -a 256 "$versions" | cut -c1-16)"
echo "Fetching $REPO release $tag"
gh release view "$tag" --repo "$REPO" >/dev/null || { echo "error: no matching Intel dependency release: $tag" >&2; exit 1; }
work="$(mktemp -d)"; trap 'rm -rf "$work"' EXIT
gh release download "$tag" --repo "$REPO" --dir "$work" --pattern '*.part-*'
gh release download "$tag" --repo "$REPO" --dir "$work" --pattern manifest.txt
[[ -s "$work/manifest.txt" ]] || { echo 'error: dependency manifest is missing or empty' >&2; exit 1; }
parts=0
while read -r name want; do
  [[ -z "${name:-}" ]] && continue
  [[ "$name" == *.part-* && "$want" =~ ^[0-9a-f]{64}$ ]] || continue
  parts=$((parts + 1))
  [[ -f "$work/$name" ]] || { echo "error: manifest part was not downloaded: $name" >&2; exit 1; }
  got="$(shasum -a 256 "$work/$name" | cut -d' ' -f1)"
  [[ "$got" == "$want" ]] || { echo "error: checksum mismatch: $name" >&2; exit 1; }
done < <(awk 'NF >= 2 && $1 !~ /^#/ { print $1, $2 }' "$work/manifest.txt")
(( parts > 0 )) || { echo 'error: dependency manifest contains no archive parts' >&2; exit 1; }
echo "Dependency part checksums: OK ($parts part(s))"
rm -rf "$DEPS_INSTALL_DIR"; mkdir -p "$DEPS_INSTALL_DIR"
cat "$work/$tag.tar.gz.part-"* | tar -xzf - -C "$DEPS_INSTALL_DIR"
echo "Installed Intel dependency tree: $DEPS_INSTALL_DIR"
