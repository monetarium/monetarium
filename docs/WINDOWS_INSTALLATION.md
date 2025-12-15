# Monetarium Windows Installation Guide

This guide provides step-by-step instructions for installing and running a Monetarium node and wallet on Windows.

## Table of Contents

1. [Introduction](#introduction)
2. [System Requirements](#system-requirements)
3. [Download Binaries](#download-binaries)
4. [Installation](#installation)
5. [Running the Node](#running-the-node-node)
6. [Running the Wallet](#running-the-wallet-wallet)
7. [Using ctl](#using-ctl)
8. [Router/NAT/Firewall Configuration](#routernatfirewall-configuration)
9. [Running as Background Service](#running-as-background-service)
10. [Connecting to Seed Nodes](#connecting-to-seed-nodes)
11. [Wallet Backup & Recovery](#wallet-backup--recovery)
12. [CPU Mining Configuration](#cpu-mining-configuration)
13. [Staking & Ticket Auto-Purchase](#staking--ticket-auto-purchase)
14. [Verification & Troubleshooting](#verification--troubleshooting)

---

## Introduction

Monetarium is a multi-coin blockchain system featuring VAR (Varta) and SKA (Skarb) coins. This guide covers:

- Installing the Monetarium node (`node.exe`) to participate in the network
- Setting up the wallet (`wallet.exe`) to manage your coins
- Configuring your network for optimal connectivity

---

## System Requirements

| Requirement | Minimum |
|-------------|---------|
| **Windows Version** | Windows 10 (64-bit) or later |
| **Disk Space** | 50 GB free (for blockchain data) |
| **RAM** | 4 GB |
| **Internet** | Stable broadband connection |
| **Architecture** | x86_64 (64-bit) |

---

## Download Binaries

### Step 1: Download from GitHub

Visit the release page:
- [Monetarium Releases](https://github.com/monetarium/monetarium/releases)

Download the following files for Windows:
- `node-windows-amd64.exe`
- `wallet-windows-amd64.exe`
- `ctl-windows-amd64.exe`

### Step 2: Verify Downloads (Optional)

If SHA256 checksums are provided, verify your downloads using PowerShell:

```powershell
Get-FileHash .\node-windows-amd64.exe -Algorithm SHA256
```

Compare the output with the checksums on the releases page.

---

## Installation

### Step 1: Create Installation Directory

Open PowerShell and run:

```powershell
New-Item -ItemType Directory -Path "C:\monetarium" -Force
```

### Step 2: Move Downloaded Binaries

Move the downloaded files to your installation directory and rename them:

```powershell
Move-Item "$env:USERPROFILE\Downloads\node-windows-amd64.exe" "C:\monetarium\node.exe"
Move-Item "$env:USERPROFILE\Downloads\wallet-windows-amd64.exe" "C:\monetarium\wallet.exe"
Move-Item "$env:USERPROFILE\Downloads\ctl-windows-amd64.exe" "C:\monetarium\ctl.exe"
```

### Step 3: Add to PATH (Optional)

To run commands from any directory, add to your PATH:

```powershell
# Add to current session
$env:PATH += ";C:\monetarium"

# Add permanently (requires admin PowerShell)
[Environment]::SetEnvironmentVariable("Path", $env:PATH + ";C:\monetarium", "User")
```

### Step 4: Handle Windows Security Warning

On first run, Windows Defender SmartScreen may block the binaries:

1. Try running the binary: `C:\monetarium\node.exe`
2. If blocked, click **"More info"** then **"Run anyway"**
3. Repeat for each binary (`node.exe`, `wallet.exe`, `ctl.exe`)

Alternatively, unblock via PowerShell (run as Administrator):

```powershell
Unblock-File -Path "C:\monetarium\node.exe"
Unblock-File -Path "C:\monetarium\wallet.exe"
Unblock-File -Path "C:\monetarium\ctl.exe"
```

---

## Running the Node (node)

The node (`node.exe`) connects to the Monetarium network and maintains a copy of the blockchain.

### First Run

```powershell
C:\monetarium\node.exe --addpeer=176.113.164.216:9108
```

On first run, node will:
- Create configuration directory at `%LOCALAPPDATA%\Dcrd\`
- Generate RPC credentials in `%LOCALAPPDATA%\Dcrd\dcrd.conf`
- Create TLS certificates for secure RPC communication
- Begin syncing the blockchain

### Configuration File

The main configuration file is located at `%LOCALAPPDATA%\Dcrd\dcrd.conf`. Key options:

```ini
; RPC credentials (auto-generated on first run)
rpcuser=your_rpc_user
rpcpass=your_rpc_password

; Add persistent peers
addpeer=176.113.164.216:9108

; Listen for incoming connections (default: true)
listen=1

; External IP (if behind NAT, set your public IP)
; externalip=your.public.ip.address
```

### Data Directories

| Path | Contents |
|------|----------|
| `%LOCALAPPDATA%\Dcrd\dcrd.conf` | Configuration file |
| `%LOCALAPPDATA%\Dcrd\data\mainnet\` | Blockchain database |
| `%LOCALAPPDATA%\Dcrd\logs\mainnet\` | Log files |
| `%LOCALAPPDATA%\Dcrd\rpc.cert` | TLS certificate |

> **Tip**: Open the folder in Explorer by running: `explorer %LOCALAPPDATA%\Dcrd`

---

## Running the Wallet (wallet)

The wallet (`wallet.exe`) manages your VAR and SKA coins.

### Prerequisites

- The node (`node.exe`) must be running
- Copy the RPC certificate from node

### Step 1: Copy RPC Certificate

```powershell
New-Item -ItemType Directory -Path "$env:LOCALAPPDATA\Dcrwallet" -Force
Copy-Item "$env:LOCALAPPDATA\Dcrd\rpc.cert" "$env:LOCALAPPDATA\Dcrwallet\"
```

### Step 2: Create Wallet

```powershell
C:\monetarium\wallet.exe --create
```

You will be prompted to:
1. Enter a **private passphrase** (encrypts your wallet - REMEMBER THIS!)
2. Optionally enter a **public passphrase** (for watching-only access)
3. Choose whether to add encryption for public data
4. **IMPORTANT**: Write down your **33-word seed phrase** and store it securely

> **WARNING**: Your seed phrase is the ONLY way to recover your wallet. Store it offline in a secure location. Never share it with anyone.

### Step 3: Start the Wallet

```powershell
C:\monetarium\wallet.exe
```

### Configuration File

The wallet configuration is at `%LOCALAPPDATA%\Dcrwallet\dcrwallet.conf`:

```ini
; Connect to local node
rpcconnect=127.0.0.1:9109

; Use node's RPC credentials
username=your_rpc_user
password=your_rpc_password

; Path to node's certificate
cafile=%LOCALAPPDATA%\Dcrwallet\rpc.cert
```

### Data Directories

| Path | Contents |
|------|----------|
| `%LOCALAPPDATA%\Dcrwallet\dcrwallet.conf` | Configuration file |
| `%LOCALAPPDATA%\Dcrwallet\mainnet\wallet.db` | Wallet database |
| `%LOCALAPPDATA%\Dcrwallet\logs\mainnet\` | Log files |

---

## Using ctl

`ctl.exe` is the command-line interface for interacting with the node and wallet.

### Basic Setup

Create a configuration file at `%LOCALAPPDATA%\Dcrctl\dcrctl.conf`:

```ini
rpcuser=your_rpc_user
rpcpass=your_rpc_password
rpcserver=127.0.0.1:9109
rpccert=%LOCALAPPDATA%\Dcrd\rpc.cert
```

Create the directory and file:

```powershell
New-Item -ItemType Directory -Path "$env:LOCALAPPDATA\Dcrctl" -Force
notepad "$env:LOCALAPPDATA\Dcrctl\dcrctl.conf"
```

### Node Commands

```powershell
# Check node sync status
C:\monetarium\ctl.exe getblockcount

# Get network info
C:\monetarium\ctl.exe getnetworkinfo

# List connected peers
C:\monetarium\ctl.exe getpeerinfo

# Get blockchain info
C:\monetarium\ctl.exe getblockchaininfo
```

### Wallet Commands

Add `--wallet` flag to interact with the wallet:

```powershell
# Get wallet balance
C:\monetarium\ctl.exe --wallet getbalance

# Generate new address
C:\monetarium\ctl.exe --wallet getnewaddress

# List transactions
C:\monetarium\ctl.exe --wallet listtransactions

# Send coins (unlocks wallet temporarily)
C:\monetarium\ctl.exe --wallet sendtoaddress "MsAddress..." 1.0
```

---

## Router/NAT/Firewall Configuration

To participate fully in the network and allow incoming connections, configure your firewall and router.

### Required Ports

| Port | Protocol | Direction | Purpose |
|------|----------|-----------|---------|
| **9108** | TCP | Inbound + Outbound | P2P node communication |
| 9109 | TCP | Localhost only | Node RPC |
| 9110 | TCP | Localhost only | Wallet JSON-RPC |
| 9111 | TCP | Localhost only | Wallet gRPC |

> **Note**: Only port **9108** needs to be opened for external access. RPC ports should remain localhost-only for security.

### Windows Defender Firewall Configuration

#### Using PowerShell (Run as Administrator)

```powershell
# Allow inbound connections for node
New-NetFirewallRule -DisplayName "Monetarium Node (Inbound)" -Direction Inbound -Program "C:\monetarium\node.exe" -Action Allow -Protocol TCP -LocalPort 9108

# Allow outbound connections for node
New-NetFirewallRule -DisplayName "Monetarium Node (Outbound)" -Direction Outbound -Program "C:\monetarium\node.exe" -Action Allow -Protocol TCP
```

#### Using Windows GUI

1. Open **Windows Security** → **Firewall & network protection**
2. Click **"Allow an app through firewall"**
3. Click **"Change settings"** (requires admin)
4. Click **"Allow another app..."**
5. Browse to `C:\monetarium\node.exe` and add it
6. Ensure both **Private** and **Public** are checked

#### Verify Firewall Rules

```powershell
Get-NetFirewallRule -DisplayName "Monetarium*" | Format-Table DisplayName, Direction, Action
```

### Router Port Forwarding

> **Note**: You may need to order a static IP from your ISP to allow incoming connections.

In most cases your global IP will point to your router, which will do the port forwarding to your node's local IP.

#### Step 1: Find Your Local IP

```powershell
Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*"} | Select-Object InterfaceAlias, IPAddress
```

Note the IP address (e.g., `192.168.1.100`)

#### Step 2: Access Router Admin Panel

1. Open browser and go to your router's admin page (typically `192.168.1.1` or `192.168.0.1`)
2. Log in with admin credentials

#### Step 3: Configure Port Forwarding

Navigate to **Port Forwarding** (may be under Advanced Settings, NAT, or Virtual Server):

| Setting | Value |
|---------|-------|
| Service Name | Monetarium |
| External Port | 9108 |
| Internal Port | 9108 |
| Protocol | TCP |
| Internal IP | Your PC's IP (e.g., 192.168.1.100) |

#### Step 4: Set Static IP (Recommended)

To prevent your IP from changing:

1. In router settings, find **DHCP Reservation** or **Address Reservation**
2. Add your PC's MAC address with a fixed IP
3. Or configure a static IP on Windows:
   - **Settings → Network & Internet → Ethernet/Wi-Fi → Edit IP settings**
   - Set to **Manual** and configure IPv4

#### Step 5: Verify Port is Open

After configuration, verify the port is accessible using an online port checker at https://www.yougetsignal.com/tools/open-ports/

---

## Running as Background Service

### Node as Windows Service

The node has built-in Windows service support. Run PowerShell as Administrator:

#### Install Service

```powershell
C:\monetarium\node.exe --service install
```

#### Start Service

```powershell
C:\monetarium\node.exe --service start
```

#### Stop Service

```powershell
C:\monetarium\node.exe --service stop
```

#### Remove Service

```powershell
C:\monetarium\node.exe --service remove
```

#### Check Service Status

```powershell
Get-Service monetariumsvc
```

#### View Service in GUI

Press `Win + R`, type `services.msc`, and find **"Monetarium Node Service"**

### Wallet as Windows Service

The wallet can also run as a Windows service when configured with auto-unlock passphrase.

#### Prerequisites

Add the passphrase to `%LOCALAPPDATA%\Dcrwallet\dcrwallet.conf`:

```ini
; Private passphrase for automatic wallet unlock
pass=YourWalletPassphrase
```

> **Security Warning**: Storing the passphrase in config reduces security. Only use this on dedicated staking/mining machines.

#### Using NSSM

Download [NSSM](https://nssm.cc/) (Non-Sucking Service Manager) and run as Administrator:

```powershell
# Install wallet as service
nssm install MonetariumWallet C:\monetarium\wallet.exe

# Start the service
nssm start MonetariumWallet

# Check status
Get-Service MonetariumWallet

# Stop service
nssm stop MonetariumWallet

# Remove service
nssm remove MonetariumWallet confirm
```

#### Using Task Scheduler (Alternative)

If you prefer not to store the passphrase in config, use Task Scheduler for manual unlock:

1. Press `Win + R`, type `taskschd.msc`
2. Click **"Create Basic Task..."**
3. Name: `Monetarium Wallet`
4. Trigger: **"When I log on"**
5. Action: **"Start a program"**
6. Program: `C:\monetarium\wallet.exe`
7. Finish and test by right-clicking → **Run**

---

## Connecting to Seed Nodes

Since Monetarium does not use DNS seeds, you must manually connect to known peers.

### Official Seed Node

```
176.113.164.216:9108
```

### Connection Methods

#### Method 1: Command Line Flag

```powershell
C:\monetarium\node.exe --addpeer=176.113.164.216:9108
```

#### Method 2: Configuration File

Add to `%LOCALAPPDATA%\Dcrd\dcrd.conf`:

```ini
addpeer=176.113.164.216:9108
```

#### Method 3: Connect-Only Mode

To connect ONLY to specific peers (no other connections):

```powershell
C:\monetarium\node.exe --connect=176.113.164.216:9108
```

### Adding Multiple Peers

```ini
; In dcrd.conf
addpeer=176.113.164.216:9108
addpeer=another.peer.ip:9108
```

---

## Wallet Backup & Recovery

### Backup Your Wallet

#### 1. Seed Phrase (Most Important)

Your 33-word seed phrase was displayed during wallet creation. This is your **primary backup**.

- Write it down on paper
- Store in a secure, fireproof location
- Never store digitally or share with anyone
- Consider using a metal backup for fire/water resistance

#### 2. Wallet File Backup

For convenience, also backup the wallet database:

```powershell
# Stop wallet first
taskkill /IM wallet.exe /F

# Copy wallet file
Copy-Item "$env:LOCALAPPDATA\Dcrwallet\mainnet\wallet.db" "D:\backup\wallet.db.backup"

# Restart wallet
C:\monetarium\wallet.exe
```

### Recover From Seed Phrase

If you need to restore your wallet on a new machine:

```powershell
# Create new wallet with existing seed
C:\monetarium\wallet.exe --create
```

When prompted:
1. Enter a new private passphrase
2. Choose **"yes"** when asked to restore from seed
3. Enter your 33-word seed phrase
4. Enter the original wallet creation date (or skip to scan all blocks)

### Recover From Wallet File

```powershell
# Stop wallet if running
taskkill /IM wallet.exe /F

# Restore wallet file
Copy-Item "D:\backup\wallet.db.backup" "$env:LOCALAPPDATA\Dcrwallet\mainnet\wallet.db"

# Start wallet
C:\monetarium\wallet.exe
```

---

## CPU Mining Configuration

Monetarium uses CPU mining with the Blake3 algorithm. Here's how to configure your node for mining.

### Check Available CPU Cores

```powershell
(Get-CimInstance Win32_Processor).NumberOfLogicalProcessors
```

This shows the total number of CPU threads available.

### Enable Mining in Configuration

Add these options to `%LOCALAPPDATA%\Dcrd\dcrd.conf`:

```ini
; Enable CPU mining
generate=1

; Mining address for block rewards (must be a VAR address starting with 'Ms')
miningaddr=MsYourAddressHere...

; Number of CPU threads for mining
; Recommendation: Use half your threads to avoid system slowdown
; Example: 8-thread CPU → use 4 threads
miningthreads=4
```

### Mining Address

Generate a mining address from your wallet:

```powershell
C:\monetarium\ctl.exe --wallet getnewaddress
```

Copy the address (starts with `Ms`) and use it as your `miningaddr`.

> **Note**: Mining rewards are paid in VAR coins. SKA coins cannot be mined.

### Recommended Thread Settings

| CPU Threads | Recommended Mining Threads | Use Case |
|-------------|---------------------------|----------|
| 4 | 2 | Light mining, daily use |
| 8 | 4 | Balanced mining |
| 16+ | 8-12 | Dedicated mining node |

### Start Mining

After configuration, restart the node:

```powershell
# If running as service
C:\monetarium\node.exe --service stop
C:\monetarium\node.exe --service start

# Or manually (stop with Ctrl+C first)
C:\monetarium\node.exe --addpeer=176.113.164.216:9108
```

### Monitor Mining

```powershell
# Check if mining is active
C:\monetarium\ctl.exe getmininginfo

# Check hashrate
C:\monetarium\ctl.exe gethashespersec
```

### Mining Tips

- **Start conservative**: Begin with fewer threads and increase if system remains responsive
- **Monitor temperature**: CPU mining generates heat; ensure adequate cooling
- **Block rewards**: New blocks pay 64 VAR, split 50% to miners, 50% to stakers
- **Block time**: Average 5 minutes per block

---

## Staking & Ticket Auto-Purchase

Staking allows you to earn rewards by participating in Monetarium's proof-of-stake voting system. You purchase "tickets" that vote on blocks and earn staking rewards.

### Prerequisites

- Synced node running
- Wallet with VAR balance (minimum ~2 VAR per ticket)
- Wallet passphrase configured for auto-unlock

### Enable Staking in Wallet Configuration

Add these options to `%LOCALAPPDATA%\Dcrwallet\dcrwallet.conf`:

```ini
; Enable automatic voting on tickets
enablevoting=1

; Enable automatic ticket purchasing
enableticketbuyer=1

; Maximum number of tickets to maintain
; Adjust based on your VAR balance
ticketbuyer.limit=20

; Minimum balance to maintain (don't spend below this)
; Keeps reserve for fees and emergencies
ticketbuyer.balancetomaintainabsolute=1

; Gap limit for address discovery
gaplimit=20
accountgaplimit=10
```

### Wallet Passphrase for Auto-Unlock

For automated staking, the wallet needs to unlock automatically. Add to `%LOCALAPPDATA%\Dcrwallet\dcrwallet.conf`:

```ini
; WARNING: Reduces security - only use on dedicated staking machines
; Private passphrase for automatic wallet unlock
pass=YourWalletPassphrase
```

> **Security Warning**: Storing the passphrase in config reduces security. Only use this on dedicated staking machines or wallets with limited balances.

### Staking Workflow

#### Step 1: Generate Staking Address

On your staking wallet:

```powershell
C:\monetarium\ctl.exe --wallet getnewaddress
```

Save this address (e.g., `MsStakingAddress...`)

#### Step 2: Send VAR from Mining Node

If mining on a separate machine, send VAR to your staking wallet:

```powershell
# On mining node's wallet
C:\monetarium\ctl.exe --wallet sendtoaddress "MsStakingAddress..." 100
```

#### Step 3: Start Staking Wallet

```powershell
C:\monetarium\wallet.exe
```

The wallet will automatically:
1. Monitor your balance
2. Purchase tickets when funds are available
3. Vote on blocks when tickets are selected
4. Receive staking rewards

### Monitor Staking

```powershell
# Check ticket status
C:\monetarium\ctl.exe --wallet getstakeinfo

# List your tickets
C:\monetarium\ctl.exe --wallet gettickets true

# Check voting status
C:\monetarium\ctl.exe --wallet walletinfo
```

### Staking Parameters

| Parameter | Mainnet Value |
|-----------|---------------|
| Minimum ticket price | ~2 VAR |
| Ticket pool size | 8,192 tickets |
| Tickets per block | 5 |
| Ticket maturity | 256 blocks |
| Ticket expiry | 40,960 blocks (~142 days) |
| Vote reward | 50% of block reward |

### Practical Tips

1. **Start small**: Buy a few tickets first to understand the process
2. **Monitor regularly**: Check `getstakeinfo` to ensure voting is working
3. **Keep balance**: Always maintain some VAR for fees
4. **Ticket timing**: Tickets take 256 blocks to mature before they can vote
5. **Patience**: Tickets may take time to be selected for voting (random selection)

### Separate Mining and Staking

For security, consider running separate wallets:

| Role | Wallet | Purpose |
|------|--------|---------|
| Mining | Hot wallet on mining node or Offline wallet (if not staking) | Receives block rewards |
| Staking | Dedicated staking wallet | Purchases tickets, votes |
| Cold storage | Offline wallet | Long-term savings |

Transfer VAR periodically from mining to staking wallet to fund ticket purchases.

---

## Verification & Troubleshooting

### Verify Node is Running

```powershell
# Check if process is running
Get-Process node -ErrorAction SilentlyContinue

# Check sync status
C:\monetarium\ctl.exe getblockcount

# Get blockchain info
C:\monetarium\ctl.exe getblockchaininfo
```

### Verify Peer Connections

```powershell
# List connected peers
C:\monetarium\ctl.exe getpeerinfo

# Check connection count
C:\monetarium\ctl.exe getconnectioncount
```

### Verify Wallet Connection

```powershell
# Check wallet is connected to node
C:\monetarium\ctl.exe --wallet getinfo

# Check balance
C:\monetarium\ctl.exe --wallet getbalance
```

### Common Issues

#### "Connection refused" when using ctl

**Cause**: Node is not running or RPC is misconfigured.

**Solution**:
```powershell
# Check if node is running
Get-Process node

# Verify RPC credentials match in:
# %LOCALAPPDATA%\Dcrd\dcrd.conf
# %LOCALAPPDATA%\Dcrctl\dcrctl.conf
```

#### Wallet won't start - "unable to open database"

**Cause**: Wallet database is corrupted or wallet is already running.

**Solution**:
```powershell
# Check if already running
Get-Process wallet

# Kill existing process
taskkill /IM wallet.exe /F

# Try again
C:\monetarium\wallet.exe
```

#### No peers connecting

**Cause**: Firewall blocking connections or no seed nodes configured.

**Solution**:
```powershell
# Ensure seed node is configured
C:\monetarium\node.exe --addpeer=176.113.164.216:9108

# Check firewall rules
Get-NetFirewallRule -DisplayName "Monetarium*"
```

#### Sync is very slow

**Cause**: Limited peer connections or network issues.

**Solution**:
- Ensure port 9108 is forwarded in your router
- Add more peers if available
- Check internet connection stability

#### Antivirus Interference

Some antivirus software may flag or quarantine Monetarium binaries.

**Solution**:
1. Add `C:\monetarium\` to your antivirus exclusion list
2. Windows Defender: **Settings → Virus & threat protection → Manage settings → Exclusions**

### Log File Locations

| Service | Log Path |
|---------|----------|
| Node | `%LOCALAPPDATA%\Dcrd\logs\mainnet\dcrd.log` |
| Wallet | `%LOCALAPPDATA%\Dcrwallet\logs\mainnet\dcrwallet.log` |

### View Logs

```powershell
# View node log (last 100 lines)
Get-Content "$env:LOCALAPPDATA\Dcrd\logs\mainnet\dcrd.log" -Tail 100

# Follow node log in real-time
Get-Content "$env:LOCALAPPDATA\Dcrd\logs\mainnet\dcrd.log" -Wait -Tail 50

# View wallet log
Get-Content "$env:LOCALAPPDATA\Dcrwallet\logs\mainnet\dcrwallet.log" -Wait -Tail 50
```

---

## Quick Reference

### Essential Commands

```powershell
# Start node
C:\monetarium\node.exe --addpeer=176.113.164.216:9108

# Start wallet
C:\monetarium\wallet.exe

# Check balance
C:\monetarium\ctl.exe --wallet getbalance

# Get new address
C:\monetarium\ctl.exe --wallet getnewaddress

# Check sync status
C:\monetarium\ctl.exe getblockcount

# List peers
C:\monetarium\ctl.exe getpeerinfo
```

### Mining Commands

```powershell
# Check mining status
C:\monetarium\ctl.exe getmininginfo

# Check hashrate
C:\monetarium\ctl.exe gethashespersec

# Check available CPU threads
(Get-CimInstance Win32_Processor).NumberOfLogicalProcessors
```

### Staking Commands

```powershell
# Check stake info
C:\monetarium\ctl.exe --wallet getstakeinfo

# List tickets
C:\monetarium\ctl.exe --wallet gettickets true

# Check wallet info
C:\monetarium\ctl.exe --wallet walletinfo
```

### Service Commands (Run as Administrator)

```powershell
# Install node service
C:\monetarium\node.exe --service install

# Start service
C:\monetarium\node.exe --service start

# Stop service
C:\monetarium\node.exe --service stop

# Remove service
C:\monetarium\node.exe --service remove

# Check service status
Get-Service monetariumsvc
```

### Default Ports

| Port | Service |
|------|---------|
| 9108 | P2P Network |
| 9109 | Node RPC |
| 9110 | Wallet JSON-RPC |
| 9111 | Wallet gRPC |

### Important Paths

| Path | Description |
|------|-------------|
| `C:\monetarium\` | Binary installation |
| `%LOCALAPPDATA%\Dcrd\` | Node data & config |
| `%LOCALAPPDATA%\Dcrwallet\` | Wallet data & config |
| `%LOCALAPPDATA%\Dcrctl\` | CLI config |

---

## Support

For additional help:
- GitHub Issues: https://github.com/monetarium/issues
- Community Discord: [Link TBD]
