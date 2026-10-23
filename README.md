# Mixar AI — Blender 5.x Intel macOS Builds

Reproducible **Intel-only (`x86_64`) macOS builds** of [Mixar](https://www.mixar.app/), a customized Blender fork with Mixar AI features.

> This is an unofficial community build. It is not affiliated with or endorsed by the Blender Foundation. Mixar remains a separate project; see the original project and license notices before redistribution.

## Download

Open **Releases** and download the `.dmg` for your Intel Mac. The release includes SHA-256 checksums and a build manifest.

The archived build was produced from the official [Mixar-AI/mixar-app](https://github.com/Mixar-AI/mixar-app) source project. Future builds use the configurable `MIXAR_SOURCE_REPOSITORY` and `MIXAR_SOURCE_REF` values in the workflow, defaulting to that official repository.

- Target: Intel `x86_64`, not universal and not Apple Silicon
- Build output: `Mixar.app` and a compressed DMG

## Install

1. Download the `.dmg` from Releases.
2. Open it and drag `Mixar.app` to `Applications`.
3. If macOS blocks this unsigned community build, right-click the app and choose **Open** once. If necessary, remove only the quarantine attribute from the app you downloaded:

```bash
xattr -cr /Applications/Mixar.app
```

Only run that command for an artifact you trust and have verified with the published SHA-256 checksum.

## Why a custom Intel dependency stack is required

Blender 5.x no longer publishes the official precompiled macOS Intel dependency directory (`upstream/lib/macos_x64`). The build therefore fetches a matching x86_64 dependency release from [`lastowl/intel-blender-5`](https://github.com/lastowl/intel-blender-5). The exact release tag is derived from Blender's `versions.cmake` SHA-256 prefix, so a changed dependency manifest fails instead of silently using a stale stack.

The community reference that inspired this automation is [`jaguarus83/blender-5x-intel-mac-builds`](https://github.com/jaguarus83/blender-5x-intel-mac-builds). This repository adds exact dependency matching, checksums, Intel architecture checks, embedded-Python checks, DMG validation, diagnostics, and optional release automation.

See [DEPENDENCIES.md](docs/DEPENDENCIES.md) for the dependency map and source links.

## Workflows

- **Legacy/manual:** [`build-intel-legacy.yml`](.github/workflows/build-intel-legacy.yml) mirrors the successful manual build path. Run it from **Actions → Build Intel DMG (legacy)**. It uploads a short-retention DMG artifact.
- **Strict/release:** [`build-intel-strict.yml`](.github/workflows/build-intel-strict.yml) is the recommended path. It fails loudly on missing dependencies, architecture mismatches, Python/runtime failures, missing app output, empty DMGs, or failed diagnostics. The workflow defaults to `Mixar-AI/mixar-app`; set `MIXAR_SOURCE_REPOSITORY` and `MIXAR_SOURCE_REF` only when building an authorized fork or pinned checkout, then dispatch it. It uploads a DMG plus manifests and targeted logs, and can create a GitHub Release when given a tag.

The strict workflow can be started manually. Upstream-release polling is opt-in via `workflow_dispatch` input; it does not run on every push or on a timer by default. GitHub-hosted Intel runners are scarce and long builds consume Actions minutes, so automatic polling should only be enabled deliberately for a release cadence you actually need.

## Verification

For a downloaded DMG, verify the release checksum before installation:

```bash
shasum -a 256 Mixar-Intel-macOS.dmg
hdiutil verify Mixar-Intel-macOS.dmg
```

The strict workflow also records executable architecture, native Mach-O counts, Python version/hash support, runtime imports, and DMG metadata in `build-manifest.txt`.

## Limitations

- Intel macOS support is community-maintained and may have Blender/Metal/GPU compatibility issues.
- The app is not Apple Developer ID signed or notarized by this repository.
- OpenAL deprecation and old static-library linker warnings may appear on modern Xcode; they are recorded in diagnostics. They are not silently treated as successful runtime tests.
- A green workflow means the scripted validations passed; it is not a guarantee that every GPU, codec, audio device, or scene works on every Intel Mac.

## License

The automation and documentation in this repository are licensed under the [GNU General Public License v3.0](LICENSE). The Mixar/Blender source and bundled dependencies retain their own licenses. Do not remove upstream license notices.

### Source configuration for maintainers

Both workflows default to the official `Mixar-AI/mixar-app` repository. Set `MIXAR_SOURCE_REPOSITORY` and `MIXAR_SOURCE_REF` only if you intentionally build an authorized fork or pinned checkout. For a private authorized checkout, add a fine-grained repository secret named `MIXAR_SOURCE_TOKEN` with read-only Contents access.
