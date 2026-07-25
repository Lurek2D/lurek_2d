# Build And Distribution

This page collects contributor-facing build and packaging guidance that should not live in user onboarding guides.

## Scope

- Use this guide when you are building the engine from source, packaging release artifacts, or formalizing platform support.
- Use [CONTRIBUTING.md](https://github.com/Lurek2D/lurek_2d/blob/main/CONTRIBUTING.md) for day-to-day setup and quality gates.
- Use [Guides](../guides/index.md) for user-facing project onboarding.

## Windows Distribution

On Windows, Lurek2D relies on native Windows graphics, audio, and system libraries. The main portability issue is usually the Visual C++ runtime.

To statically link the C runtime for release builds:

```powershell
$env:RUSTFLAGS="-C target-feature=+crt-static"
cargo build --release
```

Or configure it in `.cargo/config.toml`:

```toml
[target.x86_64-pc-windows-msvc]
rustflags = ["-C", "target-feature=+crt-static"]
```

## Linux Distribution Contract

Recommended primary Linux target:

- `x86_64-unknown-linux-gnu`

Recommended distribution artifacts:

- portable folder plus `tar.xz`
- optional AppImage

Recommended build environments:

- native Linux
- WSL2 with Ubuntu LTS
- a controlled older-glibc container when portability matters

## Why Linux Uses `gnu` First

- It matches the normal Linux desktop ABI.
- It fits `wgpu`, audio, dialogs, and desktop integration more naturally than a strict `musl` workflow.
- It works more directly with the current OpenSSL-backed `native-tls` setup.

Treat `x86_64-unknown-linux-musl` as experimental unless the packaging strategy changes.

## Linux Build Host Requirements

Ubuntu or Mint family:

```bash
sudo apt update
sudo apt install -y \
  build-essential \
  pkg-config \
  python3 \
  python3-venv \
  git \
  curl \
  libasound2-dev \
  libssl-dev \
  xdg-desktop-portal \
  xdg-desktop-portal-gtk \
  zenity \
  libvulkan1 \
  mesa-vulkan-drivers
```

Fedora:

```bash
sudo dnf install -y \
  gcc \
  gcc-c++ \
  pkgconf-pkg-config \
  python3 \
  git \
  curl \
  alsa-lib-devel \
  openssl-devel \
  xdg-desktop-portal \
  xdg-desktop-portal-gtk \
  zenity \
  vulkan-loader \
  mesa-vulkan-drivers
```

## Packaging Guidance

- Keep `release` as the shipping build profile.
- Split debug info from the shipped executable when packaging.
- Run `strip --strip-unneeded` on Linux release artifacts.
- Always compress the shipped Linux folder as `tar.xz`.
- AppImage is a good optional artifact for easier end-user distribution.
- UPX can stay optional if team policy allows it.

## Repo State Notes

- `tools/dist/dist.sh` and related packaging scripts are the implementation owners for packaging flow changes.
- Packaging policy belongs in contributor docs and build tooling, not in beginner guides.
- If distribution constraints change, keep contributor docs, scripts, and architecture notes aligned.
