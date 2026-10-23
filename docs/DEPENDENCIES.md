# Intel macOS dependency map

## Missing upstream dependency

Blender 5.x stopped shipping the official precompiled macOS Intel dependency tree at `upstream/lib/macos_x64`. The source checkout can therefore print a warning and `make update` can return an error for Intel. That is expected for this target, but the workflow does **not** silently substitute an arbitrary tree: it fetches an external dependency release and verifies that it matches the exact Blender dependency manifest.

## Sources used

- Blender source: https://projects.blender.org/blender/blender
- Blender GitHub mirror: https://github.com/blender/blender
- Intel dependency releases: https://github.com/lastowl/intel-blender-5
- Community reference builds: https://github.com/jaguarus83/blender-5x-intel-mac-builds

The official Mixar source repository is https://github.com/Mixar-AI/mixar-app. The workflow defaults to that repository; maintainers can override it only for an authorized fork or pinned checkout.

## Matching algorithm

1. Read `upstream/build_files/build_environment/cmake/versions.cmake`.
2. Compute its SHA-256.
3. Use the first 16 hexadecimal characters in the release tag:

```text
deps-x64-<sha256-prefix>
```

4. Download the release parts and verify every published part against `manifest.txt`.
5. Reject the build if the release is missing, checksums disagree, or native files are not `x86_64`.

This avoids silently using a dependency stack built for a different Blender revision.

## Python package constraint

The embedded Blender Python has no `Python.h` for arbitrary extension compilation. `cryptography` is constrained to `>=42,<49` so pip can select an Intel-compatible wheel rather than attempting a source build. The workflow installs packages with the embedded Python only; a system-pip fallback is deliberately forbidden because it can place native extensions built for the wrong ABI into the app.
