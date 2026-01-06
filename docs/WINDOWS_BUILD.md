# Monetarium Windows Build Guide

This guide provides step-by-step instructions for building Monetarium binaries from source on Windows.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Clone Repository](#clone-repository)
3. [Building the Node](#building-the-node)
4. [Building the Wallet](#building-the-wallet)
5. [Building ctl](#building-ctl)
6. [Build All at Once](#build-all-at-once)
7. [Running Tests](#running-tests)
8. [Cross-Compilation](#cross-compilation)
9. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### 1. Install Go

Monetarium requires **Go 1.23 or later**.

1. Download Go from https://go.dev/dl/
2. Run the installer (e.g., `go1.23.4.windows-amd64.msi`)
3. Verify installation:

```powershell
go version
```

Expected output: `go version go1.23.x windows/amd64`

### 2. Install Git

1. Download Git from https://git-scm.com/download/win
2. Run the installer with default settings
3. Verify installation:

```powershell
git --version
```

### 3. Install GCC (Optional, for CGO)

Some dependencies may require CGO. Install TDM-GCC or MinGW-w64:

**Option A: TDM-GCC (Recommended)**
1. Download from https://jmeubank.github.io/tdm-gcc/
2. Run installer, select "MinGW-w64 based" edition
3. Add to PATH during installation

**Option B: MinGW-w64 via MSYS2**
1. Download MSYS2 from https://www.msys2.org/
2. Run: `pacman -S mingw-w64-x86_64-gcc`
3. Add `C:\msys64\mingw64\bin` to PATH

Verify GCC installation:

```powershell
gcc --version
```

> **Note**: If you encounter CGO-related errors during build and don't need CGO, you can disable it with `$env:CGO_ENABLED="0"` before building.

---

## Clone Repository

### Step 1: Clone Monetarium

```powershell
cd C:\
git clone https://github.com/monetarium/monetarium.git
cd monetarium
```

### Step 2: Verify Directory Structure

The repository should contain the following directories:

```
monetarium/
├── monetarium-node/    # Node source code (github.com/monetarium/monetarium-node)
├── monetarium-wallet/  # Wallet source code (github.com/monetarium/monetarium-wallet)
├── monetarium-ctl/     # CLI tool source code (github.com/monetarium/monetarium-ctl)
└── docs/               # Documentation
```

Verify with:

```powershell
Get-ChildItem -Directory
```

---

## Building the Node

The node (`monetarium-node.exe`) must be built first, as other components depend on its modules.

### Step 1: Navigate to Node Directory

```powershell
cd C:\monetarium\monetarium-node
```

### Step 2: Download Dependencies

```powershell
go mod download
```

### Step 3: Build

```powershell
go build -o ..\monetarium-node.exe .
```

### Step 4: Verify Build

```powershell
..\monetarium-node.exe --version
```

### Build with Optimizations (Release Build)

For production builds with smaller binary size:

```powershell
go build -ldflags="-s -w" -o ..\monetarium-node.exe .
```

Flags explained:
- `-s`: Omit symbol table
- `-w`: Omit DWARF debugging information

---

## Building the Wallet

The wallet (`monetarium-wallet.exe`) depends on node modules via local `replace` directives.

### Step 1: Navigate to Wallet Directory

```powershell
cd C:\monetarium\monetarium-wallet
```

### Step 2: Download Dependencies

```powershell
go mod download
```

### Step 3: Build

```powershell
go build -o ..\monetarium-wallet.exe .
```

### Step 4: Verify Build

```powershell
..\monetarium-wallet.exe --version
```

### Build with Optimizations

```powershell
go build -ldflags="-s -w" -o ..\monetarium-wallet.exe .
```

---

## Building monetarium-ctl

The CLI tool (`monetarium-ctl.exe`) depends on both node and wallet modules.

### Step 1: Navigate to CTL Directory

```powershell
cd C:\monetarium\monetarium-ctl
```

### Step 2: Download Dependencies

```powershell
go mod download
```

### Step 3: Build

```powershell
go build -o ..\monetarium-ctl.exe .
```

### Step 4: Verify Build

```powershell
..\monetarium-ctl.exe --version
```

### Build with Optimizations

```powershell
go build -ldflags="-s -w" -o ..\monetarium-ctl.exe .
```

---

## Build All at Once

Use this PowerShell script to build all binaries in the correct order:

```powershell
# Navigate to monetarium root
cd C:\monetarium

# Build monetarium-node
Write-Host "Building monetarium-node..." -ForegroundColor Cyan
Set-Location monetarium-node
go build -ldflags="-s -w" -o ..\monetarium-node.exe .
if ($LASTEXITCODE -ne 0) { Write-Host "monetarium-node build failed!" -ForegroundColor Red; exit 1 }

# Build monetarium-wallet
Write-Host "Building monetarium-wallet..." -ForegroundColor Cyan
Set-Location ..\monetarium-wallet
go build -ldflags="-s -w" -o ..\monetarium-wallet.exe .
if ($LASTEXITCODE -ne 0) { Write-Host "monetarium-wallet build failed!" -ForegroundColor Red; exit 1 }

# Build monetarium-ctl
Write-Host "Building monetarium-ctl..." -ForegroundColor Cyan
Set-Location ..\monetarium-ctl
go build -ldflags="-s -w" -o ..\monetarium-ctl.exe .
if ($LASTEXITCODE -ne 0) { Write-Host "monetarium-ctl build failed!" -ForegroundColor Red; exit 1 }

# Return to root and verify
Set-Location ..
Write-Host "`nBuild complete! Binaries:" -ForegroundColor Green
Get-ChildItem *.exe | Format-Table Name, Length, LastWriteTime
```

Save as `build.ps1` and run with:

```powershell
.\build.ps1
```

---

## Running Tests

### Test Node

```powershell
cd C:\monetarium\monetarium-node
go test ./...
```

Or run the test script if available:

```powershell
.\run_tests.sh  # Requires Git Bash or WSL
```

### Test Wallet

```powershell
cd C:\monetarium\monetarium-wallet
go test ./...
```

### Test monetarium-ctl

```powershell
cd C:\monetarium\monetarium-ctl
go test ./...
```

### Run Tests with Verbose Output

```powershell
go test -v ./...
```

### Run Tests with Race Detection

```powershell
go test -race ./...
```

---

## Cross-Compilation

Build Windows binaries from Linux or macOS.

### From Linux/macOS to Windows

```bash
# Build monetarium-node for Windows
cd monetarium-node
GOOS=windows GOARCH=amd64 go build -o ../monetarium-node.exe .

# Build monetarium-wallet for Windows
cd ../monetarium-wallet
GOOS=windows GOARCH=amd64 go build -o ../monetarium-wallet.exe .

# Build monetarium-ctl for Windows
cd ../monetarium-ctl
GOOS=windows GOARCH=amd64 go build -o ../monetarium-ctl.exe .
```

### Build for Multiple Platforms

```bash
# Build for Windows AMD64
GOOS=windows GOARCH=amd64 go build -o monetarium-node-windows-amd64.exe .

# Build for Linux AMD64
GOOS=linux GOARCH=amd64 go build -o monetarium-node-linux-amd64 .

# Build for macOS AMD64 (Intel)
GOOS=darwin GOARCH=amd64 go build -o monetarium-node-darwin-amd64 .

# Build for macOS ARM64 (Apple Silicon)
GOOS=darwin GOARCH=arm64 go build -o monetarium-node-darwin-arm64 .
```

---

## Troubleshooting

### "go: command not found"

**Cause**: Go is not in PATH.

**Solution**:
1. Verify Go installation: `where go`
2. Add Go to PATH:
   ```powershell
   $env:PATH += ";C:\Program Files\Go\bin"
   ```
3. Or reinstall Go and ensure "Add to PATH" is selected

### "gcc: command not found" or CGO errors

**Cause**: CGO is enabled but GCC is not installed.

**Solution A**: Install GCC (see Prerequisites)

**Solution B**: Disable CGO if not needed:
```powershell
$env:CGO_ENABLED = "0"
go build -o ..\monetarium-node.exe .
```

### Module dependency errors

**Cause**: Local module replacements not found.

**Solution**: Ensure you're building from the correct directory structure:
```
monetarium/
├── monetarium-node/
├── monetarium-wallet/
└── monetarium-ctl/
```

The `go.mod` files use relative paths like `replace => ../monetarium-node/...`

### "Access denied" or permission errors

**Cause**: Antivirus or Windows Defender blocking builds.

**Solution**:
1. Add `C:\monetarium` to antivirus exclusions
2. Run PowerShell as Administrator if needed
3. Temporarily disable real-time protection during build

### Build is very slow

**Cause**: First build downloads all dependencies.

**Solution**:
- Subsequent builds will be faster due to caching
- Use `go mod download` first to pre-fetch dependencies
- Enable module caching:
  ```powershell
  $env:GOPROXY = "https://proxy.golang.org,direct"
  ```

### "package ... is not in GOROOT"

**Cause**: Module mode not enabled or wrong directory.

**Solution**:
1. Ensure you're in the correct directory (e.g., `monetarium-node/`)
2. Verify `go.mod` exists in the directory
3. Enable module mode:
   ```powershell
   $env:GO111MODULE = "on"
   ```

---

## Quick Reference

### Build Commands

| Component | Directory | Build Command |
|-----------|-----------|---------------|
| Node | `monetarium-node/` | `go build -o ..\monetarium-node.exe .` |
| Wallet | `monetarium-wallet/` | `go build -o ..\monetarium-wallet.exe .` |
| ctl | `monetarium-ctl/` | `go build -o ..\monetarium-ctl.exe .` |

### Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `CGO_ENABLED` | Enable/disable CGO | `0` or `1` |
| `GOOS` | Target operating system | `windows`, `linux`, `darwin` |
| `GOARCH` | Target architecture | `amd64`, `arm64` |
| `GOPROXY` | Module proxy | `https://proxy.golang.org,direct` |

### Useful Commands

```powershell
# Check Go environment
go env

# Clean build cache
go clean -cache

# Update dependencies
go mod tidy

# Verify dependencies
go mod verify

# List all dependencies
go list -m all
```

---

## Support

For build issues:
- GitHub Issues: https://github.com/monetarium/issues
- Community Discord: [Link TBD]
