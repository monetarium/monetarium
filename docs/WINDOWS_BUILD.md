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
├── dcrd/        # Node source code
├── dcrwallet/   # Wallet source code
├── dcrctl/      # CLI tool source code
└── docs/        # Documentation
```

Verify with:

```powershell
Get-ChildItem -Directory
```

---

## Building the Node

The node (`node.exe`) must be built first, as other components depend on its modules.

### Step 1: Navigate to dcrd Directory

```powershell
cd C:\monetarium\dcrd
```

### Step 2: Download Dependencies

```powershell
go mod download
```

### Step 3: Build

```powershell
go build -o ..\node.exe .
```

### Step 4: Verify Build

```powershell
..\node.exe --version
```

### Build with Optimizations (Release Build)

For production builds with smaller binary size:

```powershell
go build -ldflags="-s -w" -o ..\node.exe .
```

Flags explained:
- `-s`: Omit symbol table
- `-w`: Omit DWARF debugging information

---

## Building the Wallet

The wallet (`wallet.exe`) depends on dcrd modules via local `replace` directives.

### Step 1: Navigate to dcrwallet Directory

```powershell
cd C:\monetarium\dcrwallet
```

### Step 2: Download Dependencies

```powershell
go mod download
```

### Step 3: Build

```powershell
go build -o ..\wallet.exe .
```

### Step 4: Verify Build

```powershell
..\wallet.exe --version
```

### Build with Optimizations

```powershell
go build -ldflags="-s -w" -o ..\wallet.exe .
```

---

## Building ctl

The CLI tool (`ctl.exe`) depends on both dcrd and dcrwallet modules.

### Step 1: Navigate to dcrctl Directory

```powershell
cd C:\monetarium\dcrctl
```

### Step 2: Download Dependencies

```powershell
go mod download
```

### Step 3: Build

```powershell
go build -o ..\ctl.exe .
```

### Step 4: Verify Build

```powershell
..\ctl.exe --version
```

### Build with Optimizations

```powershell
go build -ldflags="-s -w" -o ..\ctl.exe .
```

---

## Build All at Once

Use this PowerShell script to build all binaries in the correct order:

```powershell
# Navigate to monetarium root
cd C:\monetarium

# Build node
Write-Host "Building node..." -ForegroundColor Cyan
Set-Location dcrd
go build -ldflags="-s -w" -o ..\node.exe .
if ($LASTEXITCODE -ne 0) { Write-Host "node build failed!" -ForegroundColor Red; exit 1 }

# Build wallet
Write-Host "Building wallet..." -ForegroundColor Cyan
Set-Location ..\dcrwallet
go build -ldflags="-s -w" -o ..\wallet.exe .
if ($LASTEXITCODE -ne 0) { Write-Host "wallet build failed!" -ForegroundColor Red; exit 1 }

# Build ctl
Write-Host "Building ctl..." -ForegroundColor Cyan
Set-Location ..\dcrctl
go build -ldflags="-s -w" -o ..\ctl.exe .
if ($LASTEXITCODE -ne 0) { Write-Host "ctl build failed!" -ForegroundColor Red; exit 1 }

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
cd C:\monetarium\dcrd
go test ./...
```

Or run the test script if available:

```powershell
.\run_tests.sh  # Requires Git Bash or WSL
```

### Test Wallet

```powershell
cd C:\monetarium\dcrwallet
go test ./...
```

### Test ctl

```powershell
cd C:\monetarium\dcrctl
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
# Build node for Windows
cd dcrd
GOOS=windows GOARCH=amd64 go build -o ../node.exe .

# Build wallet for Windows
cd ../dcrwallet
GOOS=windows GOARCH=amd64 go build -o ../wallet.exe .

# Build ctl for Windows
cd ../dcrctl
GOOS=windows GOARCH=amd64 go build -o ../ctl.exe .
```

### Build for Multiple Platforms

```bash
# Build for Windows AMD64
GOOS=windows GOARCH=amd64 go build -o node-windows-amd64.exe .

# Build for Linux AMD64
GOOS=linux GOARCH=amd64 go build -o node-linux-amd64 .

# Build for macOS AMD64 (Intel)
GOOS=darwin GOARCH=amd64 go build -o node-darwin-amd64 .

# Build for macOS ARM64 (Apple Silicon)
GOOS=darwin GOARCH=arm64 go build -o node-darwin-arm64 .
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
go build -o ..\node.exe .
```

### Module dependency errors

**Cause**: Local module replacements not found.

**Solution**: Ensure you're building from the correct directory structure:
```
monetarium/
├── dcrd/
├── dcrwallet/
└── dcrctl/
```

The `go.mod` files use relative paths like `replace => ../dcrd/...`

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
1. Ensure you're in the correct directory (e.g., `dcrd/`)
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
| Node | `dcrd/` | `go build -o ..\node.exe .` |
| Wallet | `dcrwallet/` | `go build -o ..\wallet.exe .` |
| ctl | `dcrctl/` | `go build -o ..\ctl.exe .` |

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
