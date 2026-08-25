# BaiduPCS-Go Setup

Use this reference to install and configure BaiduPCS-Go (the enhanced Go-based command-line client for Baidu Netdisk) on a host, and perform headless QR authentication using Playwright.

## Workflow

1. Check **Prerequisites** and existing `BaiduPCS-Go` binary in `$PATH`.
2. Install required toolchain (Go and Playwright) using **Toolchain Installation**.
3. Install or compile the `BaiduPCS-Go` binary following **Install BaiduPCS-Go**.
4. Authenticate using the automated Playwright QR login script or manual cookie methods in **Authentication**.
5. Run **Verify** to confirm active account and storage quota.

If the task does not map cleanly to these steps, use your native planning tool with the documented installation options, login helpers, and verification checks; do not print or leak session credentials.

## Prerequisites

- `git` and `curl` for fetching sources or releases.
- `go` (1.20+) if compiling from source.
- `pixi`, `uv`, or `python3` with `pip` for provisioning Playwright.
- Network access to GitHub, Go proxy, and `pan.baidu.com` / `passport.baidu.com`.

## Toolchain Installation

### Option 1: Pixi Global (Preferred on Pixi-managed dev boxes)

```bash
pixi global install go
pixi global install playwright-python
playwright install chromium
```

### Option 2: Standalone Python & System Go

```bash
# Verify or install system Go
command -v go || sudo apt-get install -y golang-go

# Install Playwright and Chromium headless binaries
pip install --user playwright
python3 -m playwright install chromium
```

## Install BaiduPCS-Go

Check if already installed:

```bash
command -v BaiduPCS-Go || command -v baidupcs-go
```

### Method A: Build from Source (Recommended)

Building from the upstream maintained fork ([qjfoidnh/BaiduPCS-Go](https://github.com/qjfoidnh/BaiduPCS-Go)) ensures compatibility with current Baidu Netdisk APIs:

```bash
# 1. Clone repository into a temporary or build directory
git clone https://github.com/qjfoidnh/BaiduPCS-Go.git /tmp/BaiduPCS-Go-build
cd /tmp/BaiduPCS-Go-build

# 2. Build with CGO_ENABLED=0 (ensures a portable static binary)
CGO_ENABLED=0 go build -v -ldflags "-s -w" -o BaiduPCS-Go

# 3. Install to user binary PATH
mkdir -p "$HOME/.local/bin"
mv BaiduPCS-Go "$HOME/.local/bin/BaiduPCS-Go"
chmod +x "$HOME/.local/bin/BaiduPCS-Go"

# 4. Clean up build directory
cd / && rm -rf /tmp/BaiduPCS-Go-build
```

Ensure `$HOME/.local/bin` (or `$HOME/.pixi/bin`) is in `$PATH`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

### Method B: Prebuilt GitHub Release

If Go is not installed on the target machine:

```bash
# Determine OS and Architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
case "$ARCH" in
  x86_64) ARCH="amd64" ;;
  aarch64|arm64) ARCH="arm64" ;;
  armv7*) ARCH="armv7" ;;
esac

# Download latest release asset from qjfoidnh/BaiduPCS-Go
TAG=$(curl -s https://api.github.com/repos/qjfoidnh/BaiduPCS-Go/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
ASSET_NAME="BaiduPCS-Go-${TAG}-${OS}-${ARCH}.zip"
DOWNLOAD_URL="https://github.com/qjfoidnh/BaiduPCS-Go/releases/download/${TAG}/${ASSET_NAME}"

mkdir -p /tmp/baidupcs-release && cd /tmp/baidupcs-release
curl -fSL "$DOWNLOAD_URL" -o release.zip
unzip release.zip

mkdir -p "$HOME/.local/bin"
cp BaiduPCS-Go*/*/BaiduPCS-Go "$HOME/.local/bin/BaiduPCS-Go" || cp BaiduPCS-Go "$HOME/.local/bin/BaiduPCS-Go"
chmod +x "$HOME/.local/bin/BaiduPCS-Go"
cd / && rm -rf /tmp/baidupcs-release
```

## Authentication

### Method 1: Playwright Automated QR Login (Recommended)

Use the bundled script in `<skill-dir>/scripts/baidupcs-playwright-login.py`. This runs Chromium in headless mode, grabs the QR code, saves the image, waits for mobile app scanning, captures the `BDUSS` and `STOKEN` cookies, and authenticates `BaiduPCS-Go` automatically:

```bash
<skill-root>/scripts/baidupcs-playwright-login.py --qr-path ./qrcode.png --timeout 600
```

Procedure:
1. Run the script above. It saves the QR code screenshot to `./qrcode.png`.
2. Present or view the QR code image.
3. Scan using the **Baidu Netdisk App (百度网盘)** or **Baidu App (百度)** on a mobile phone and confirm login.
4. The script detects authentication, pulls cookies (`BDUSS`, `STOKEN`, `BDCLND`, etc.), and executes `BaiduPCS-Go login -cookies="..."`.

### Method 2: Direct Cookie Login

If cookies are already exported from an existing browser session on `pan.baidu.com`:

```bash
BaiduPCS-Go login -cookies="BAIDUID=...; BDUSS=...; STOKEN=...; PANPSC=..."
```

### Method 3: BDUSS + STOKEN

```bash
BaiduPCS-Go login -bduss="<YOUR_BDUSS>" -stoken="<YOUR_STOKEN>"
```

> **Note**: `STOKEN` must be extracted from the `pan.baidu.com` domain cookies (not `passport.baidu.com`), otherwise file transfer and rapid upload operations will fail.

## Verify

Check authenticated user information:

```bash
BaiduPCS-Go who
```

Expected output:
```text
当前帐号 uid: <UID>, 用户名: <USERNAME>, 性别: ..., 年龄: ...
```

Check storage quota:

```bash
BaiduPCS-Go quota
```

Expected output:
```text
用户名: <USERNAME>, 总空间: ...TB, 已用空间: ...GB, 比率: ...%
```

Test listing root directory:

```bash
BaiduPCS-Go ls /
```

## Pitfalls & Common Issues

- **CGO Compilation Failure**: Always build with `CGO_ENABLED=0 go build`. Without `CGO_ENABLED=0`, Go might look for host C cross-compilers (e.g. `x86_64-conda-linux-gnu-cc`).
- **Headless Server Environments**: In containerized or remote Linux environments without X11/Wayland, Playwright must run with `headless=True` and sandbox flags (`--no-sandbox`, `--disable-dev-shm-usage`).
- **QR Code Expiration**: Baidu login QR codes expire after ~3–5 minutes. If scanning takes longer, the script automatically detects the expiration state and clicks refresh.
- **Config Storage**: `BaiduPCS-Go` stores user sessions and configuration files in `$HOME/.config/BaiduPCS-Go/pcs_config.json`.
