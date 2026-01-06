# Monetarium macOS Installation Guide

This guide provides step-by-step instructions for installing and running a Monetarium node and wallet on macOS.

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

- Installing the Monetarium node (`monetarium`) to participate in the network
- Setting up the wallet (`monetarium-wallet`) to manage your coins
- Configuring your network for optimal connectivity

---

## System Requirements

| Requirement | Minimum |
|-------------|---------|
| **macOS Version** | 10.15 (Catalina) or later |
| **Disk Space** | 50 GB free (for blockchain data) |
| **RAM** | 4 GB |
| **Internet** | Stable broadband connection |
| **Architecture** | Intel (x86_64) or Apple Silicon (arm64) |

---

## Download Binaries

### Step 1: Identify Your Architecture

Open Terminal and run:

```bash
uname -m
```

- `x86_64` = Intel Mac → download **amd64** binaries
- `arm64` = Apple Silicon (M1/M2/M3) → download **arm64** binaries

### Step 2: Download from GitHub

Visit the release pages:
- [node](https://github.com/monetarium/monetarium-node/releases)
- [wallet](https://github.com/monetarium/monetarium-wallet/releases)
- [ctl](https://github.com/monetarium/monetarium-ctl/releases)

Download the following files for your architecture:

**For Intel Macs (amd64):**
- `monetarium-node-darwin-amd64`
- `monetarium-wallet-darwin-amd64`
- `monetarium-ctl-darwin-amd64`

**For Apple Silicon (arm64):**
- `monetarium-node-darwin-arm64`
- `monetarium-wallet-darwin-arm64`
- `monetarium-ctl-darwin-arm64`

### Step 3: Verify Downloads (Optional)

If SHA256 checksums are provided, verify your downloads:

```bash
shasum -a 256 monetarium-*-darwin-*
```

Compare the output with the checksums on the releases page.

---

## Installation

### Step 1: Create Installation Directory

```bash
mkdir -p ~/monetarium
cd ~/monetarium
```

### Step 2: Move Downloaded Binaries

Move the downloaded files to your installation directory:

```bash
mv ~/Downloads/monetarium-node-darwin-* ~/monetarium/monetarium-node
mv ~/Downloads/monetarium-wallet-darwin-* ~/monetarium/monetarium-wallet
mv ~/Downloads/monetarium-ctl-darwin-* ~/monetarium/monetarium-ctl
```

### Step 3: Make Binaries Executable

```bash
chmod +x ~/monetarium/monetarium-node
chmod +x ~/monetarium/monetarium-wallet
chmod +x ~/monetarium/monetarium-ctl
```

### Step 4: Add to PATH (Optional)

To run commands from any directory, add to your shell profile:

```bash
echo 'export PATH="$HOME/monetarium:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Step 5: Handle macOS Security Warning

On first run, macOS may block the binaries. To allow them:

1. Try running the binary: `~/monetarium/monetarium-node`
2. If blocked, go to **System Preferences → Security & Privacy → General**
3. Click **"Allow Anyway"** next to the blocked app message
4. Repeat for each binary (`monetarium-node`, `monetarium-wallet`, `monetarium-ctl`)

Alternatively, remove the quarantine attribute:

```bash
xattr -d com.apple.quarantine ~/monetarium/monetarium-node
xattr -d com.apple.quarantine ~/monetarium/monetarium-wallet
xattr -d com.apple.quarantine ~/monetarium/monetarium-ctl
```

---

## Running the Node (monetarium-node)

The node (`monetarium-node`) connects to the Monetarium network and maintains a copy of the blockchain.

### First Run

```bash
~/monetarium/monetarium-node --addpeer=176.113.164.216:9108
```

On first run, monetarium-node will:
- Create configuration directory at `~/Library/"Application Support"/Monetarium/`
- Generate RPC credentials in `~/Library/"Application Support"/Monetarium/monetarium.conf`
- Create TLS certificates for secure RPC communication
- Begin syncing the blockchain

### Configuration File

The main configuration file is located at `~/Library/"Application Support"/Monetarium/monetarium.conf`. Key options:

```ini
; RPC credentials (auto-generated on first run)
rpcuser=your_rpc_user
rpcpass=your_rpc_password

; Add persistent peers
addpeer=176.113.164.216:9108

; External IP (if behind NAT, set your public IP)
; externalip=your.public.ip.address
```

### Data Directories

| Path | Contents |
|------|----------|
| `~/Library/"Application Support"/Monetarium/monetarium.conf` | Configuration file |
| `~/Library/"Application Support"/Monetarium/data/mainnet/` | Blockchain database |
| `~/Library/"Application Support"/Monetarium/logs/mainnet/` | Log files |
| `~/Library/"Application Support"/Monetarium/rpc.cert` | TLS certificate |

---

## Running the Wallet (monetarium-wallet)

The wallet (`monetarium-wallet`) manages your VAR and SKA coins.

### Prerequisites

- The node (`monetarium-node`) must be running

### Step 1: Create Wallet

```bash
~/monetarium/monetarium-wallet --create
```

You will be prompted to:
1. Enter a **private passphrase** (encrypts your wallet - REMEMBER THIS!)
2. Optionally enter a **public passphrase** (for watching-only access)
3. Choose whether to add encryption for public data
4. **IMPORTANT**: Write down your **33-word seed phrase** and store it securely

> **WARNING**: Your seed phrase is the ONLY way to recover your wallet. Store it offline in a secure location. Never share it with anyone.

### Step 2: Start the Wallet

```bash
~/monetarium/monetarium-wallet
```

### Configuration File

The wallet configuration is at `~/Library/"Application Support"/Monetarium-wallet/monetarium-wallet.conf`:

```ini
; Connect to local node
rpcconnect=127.0.0.1:9109

; Use node's RPC credentials
username=your_rpc_user
password=your_rpc_password
```

### Data Directories

| Path | Contents |
|------|----------|
| `~/Library/"Application Support"/Monetarium-wallet/monetarium-wallet.conf` | Configuration file |
| `~/Library/"Application Support"/Monetarium-wallet/mainnet/wallet.db` | Wallet database |
| `~/Library/"Application Support"/Monetarium-wallet/logs/mainnet/` | Log files |

---

## Using monetarium-ctl

`monetarium-ctl` is the command-line interface for interacting with the node and wallet.

### Basic Setup

Create a configuration file at `~/Library/"Application Support"/Monetarium-ctl/monetarium-ctl.conf`:

```bash
mkdir -p ~/Library/"Application Support"/Monetarium-ctl
```

```ini
rpcuser=your_rpc_user
rpcpass=your_rpc_password
```

### Node Commands

```bash
# Check node sync status
~/monetarium/monetarium-ctl getblockcount

# Get network info
~/monetarium/monetarium-ctl getnetworkinfo

# List connected peers
~/monetarium/monetarium-ctl getpeerinfo

# Get blockchain info
~/monetarium/monetarium-ctl getblockchaininfo
```

### Wallet Commands

Add `--wallet` flag to interact with the wallet:

```bash
# Get wallet balance
~/monetarium/monetarium-ctl --wallet getbalance

# Generate new address
~/monetarium/monetarium-ctl --wallet getnewaddress

# List transactions
~/monetarium/monetarium-ctl --wallet listtransactions

# Send coins (unlocks wallet temporarily)
~/monetarium/monetarium-ctl --wallet sendtoaddress "MsAddress..." 1.0
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

### macOS Firewall Configuration

#### Check Firewall Status

```bash
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
```

#### Allow monetarium-node Through Firewall

```bash
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add ~/monetarium/monetarium-node
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp ~/monetarium/monetarium-node
```

#### Verify Settings

```bash
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --listapps
```

### Router Port Forwarding

> **Note**: You may need to order global static IP from your ISP to allow incoming connections. 

In most cases your global IP will point to your router, which will do the port forwarding to local IP of your node.

To accept incoming connections, configure your router to forward port 9108:

#### Step 1: Find Your Local IP

```bash
ipconfig getifaddr en0
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
| Internal IP | Your Mac's IP (e.g., 192.168.1.100) |

#### Step 4: Set Static IP (Recommended)

To prevent your IP from changing:

1. In router settings, find **DHCP Reservation** or **Address Reservation**
2. Add your Mac's MAC address with a fixed IP
3. Or configure a static IP on your Mac:
   - **System Preferences → Network → Advanced → TCP/IP**
   - Set **Configure IPv4** to **Manually**

#### Step 5: Verify Port is Open

After configuration, verify the port is accessible:

```bash
# From another network or use online port checker
nc -zv your.public.ip 9108
```

Or use an online port checker at https://www.yougetsignal.com/tools/open-ports/

---

## Running as Background Service

Use macOS `launchd` to run Monetarium services automatically.

First make sure `~/Library/LaunchAgents` exists or create it if needed `mkdir -p ~/Library/LaunchAgents`.

### monetarium-node Service

Create the plist file:

```bash
cat > ~/Library/LaunchAgents/com.monetarium.node.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.monetarium.node</string>

    <key>ProgramArguments</key>
    <array>
        <string>/Users/YOUR_USERNAME/monetarium/monetarium-node</string>
        <string>--addpeer=176.113.164.216:9108</string>
    </array>

    <key>WorkingDirectory</key>
    <string>/Users/YOUR_USERNAME/monetarium</string>

    <key>RunAtLoad</key>
    <true/>

    <key>KeepAlive</key>
    <true/>

    <key>StandardOutPath</key>
    <string>/Users/YOUR_USERNAME/Library/Application Support/Monetarium/logs/launchd-stdout.log</string>

    <key>StandardErrorPath</key>
    <string>/Users/YOUR_USERNAME/Library/Application Support/Monetarium/logs/launchd-stderr.log</string>
</dict>
</plist>
EOF
```

**Important**: Replace `YOUR_USERNAME` with your actual macOS username:

```bash
sed -i '' "s/YOUR_USERNAME/$USER/g" ~/Library/LaunchAgents/com.monetarium.node.plist
```

### monetarium-wallet Service

Create the wallet service (starts after node):

```bash
cat > ~/Library/LaunchAgents/com.monetarium.wallet.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.monetarium.wallet</string>

    <key>ProgramArguments</key>
    <array>
        <string>/Users/YOUR_USERNAME/monetarium/monetarium-wallet</string>
    </array>

    <key>WorkingDirectory</key>
    <string>/Users/YOUR_USERNAME/monetarium</string>

    <key>RunAtLoad</key>
    <true/>

    <key>KeepAlive</key>
    <true/>

    <key>StandardOutPath</key>
    <string>/Users/YOUR_USERNAME/Library/Application Support/Monetarium-wallet/logs/launchd-stdout.log</string>

    <key>StandardErrorPath</key>
    <string>/Users/YOUR_USERNAME/Library/Application Support/Monetarium-wallet/logs/launchd-stderr.log</string>
</dict>
</plist>
EOF

sed -i '' "s/YOUR_USERNAME/$USER/g" ~/Library/LaunchAgents/com.monetarium.wallet.plist
```

> **Important**: When running the wallet as a service, it starts in a locked state and cannot sign transactions or vote on tickets. To enable full functionality, you must either:
> 1. Add `pass=YourWalletPassphrase` to `~/Library/"Application Support"/Monetarium-wallet/monetarium-wallet.conf` (see [Staking & Ticket Auto-Purchase](#staking--ticket-auto-purchase) section), OR
> 2. Manually unlock the wallet after the service starts using: `~/monetarium/monetarium-ctl --wallet walletpassphrase "YourPassphrase" 0`

### Service Management

```bash
# Load and start node
launchctl load ~/Library/LaunchAgents/com.monetarium.node.plist

# Load and start wallet
launchctl load ~/Library/LaunchAgents/com.monetarium.wallet.plist

# Stop node
launchctl unload ~/Library/LaunchAgents/com.monetarium.node.plist

# Stop wallet
launchctl unload ~/Library/LaunchAgents/com.monetarium.wallet.plist

# Check status
launchctl list | grep monetarium

# View logs
tail -f ~/Library/"Application Support"/Monetarium/logs/launchd-stdout.log
tail -f ~/Library/"Application Support"/Monetarium-wallet/logs/launchd-stdout.log
```

### Disable Auto-Start

To prevent services from starting at login:

```bash
launchctl unload -w ~/Library/LaunchAgents/com.monetarium.node.plist
launchctl unload -w ~/Library/LaunchAgents/com.monetarium.wallet.plist
```

---

## Connecting to Seed Nodes

Since Monetarium does not use DNS seeds, you must manually connect to known peers.

### Official Seed Node

```
176.113.164.216:9108
```

### Connection Methods

#### Method 1: Command Line Flag

```bash
~/monetarium/monetarium-node --addpeer=176.113.164.216:9108
```

#### Method 2: Configuration File

Add to `~/Library/"Application Support"/Monetarium/monetarium.conf`:

```ini
addpeer=176.113.164.216:9108
```

#### Method 3: Connect-Only Mode

To connect ONLY to specific peers (no other connections):

```bash
~/monetarium/monetarium-node --connect=176.113.164.216:9108
```

### Adding Multiple Peers

```ini
; In monetarium.conf
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

```bash
# Stop wallet first
launchctl unload ~/Library/LaunchAgents/com.monetarium.wallet.plist

# Copy wallet file
cp ~/Library/"Application Support"/Monetarium-wallet/mainnet/wallet.db ~/backup/wallet.db.backup

# Restart wallet
launchctl load ~/Library/LaunchAgents/com.monetarium.wallet.plist
```

### Recover From Seed Phrase

If you need to restore your wallet on a new machine:

```bash
# Create new wallet with existing seed
~/monetarium/monetarium-wallet --create
```

When prompted:
1. Enter a new private passphrase
2. Choose **"yes"** when asked to restore from seed
3. Enter your 33-word seed phrase
4. Enter the original wallet creation date (or skip to scan all blocks)

### Recover From Wallet File

```bash
# Stop wallet if running
launchctl unload ~/Library/LaunchAgents/com.monetarium.wallet.plist

# Restore wallet file
cp ~/backup/wallet.db.backup ~/Library/"Application Support"/Monetarium-wallet/mainnet/wallet.db

# Start wallet
~/monetarium/monetarium-wallet
```

---

## CPU Mining Configuration

Monetarium uses CPU mining with the Blake3 algorithm. Here's how to configure your node for mining.

### Check Available CPU Cores

```bash
sysctl -n hw.ncpu
```

This shows the total number of CPU cores available.

### Enable Mining in Configuration

Add these options to `~/Library/"Application Support"/Monetarium/monetarium.conf`:

```ini
; Enable CPU mining
generate=1

; Mining address for block rewards (must be a VAR address starting with 'Ms')
miningaddr=MsYourAddressHere...
```

### Mining Address

Generate a mining address from your wallet:

```bash
~/monetarium/monetarium-ctl --wallet getnewaddress
```

Copy the address (starts with `Ms`) and use it as your `miningaddr`.

> **Note**: Mining rewards are paid in VAR coins. SKA coins cannot be mined.

### Recommended Thread Settings

| CPU Cores | Recommended Threads | Use Case |
|-----------|---------------------|----------|
| 4 | 2 | Light mining, daily use |
| 8 | 4 | Balanced mining |
| 10+ | 6-8 | Dedicated mining node |

### Start Mining

After configuration, restart the node:

```bash
# If running as service
launchctl unload ~/Library/LaunchAgents/com.monetarium.node.plist
launchctl load ~/Library/LaunchAgents/com.monetarium.node.plist

# Or manually
~/monetarium/monetarium-node --addpeer=176.113.164.216:9108
```

### Control Mining Threads

Use `setgenerate` RPC command to enable mining and set thread count:

```bash
# Enable mining with 4 threads
~/monetarium/monetarium-ctl setgenerate true 4

# Enable mining with 1 thread (default)
~/monetarium/monetarium-ctl setgenerate true

# Disable mining
~/monetarium/monetarium-ctl setgenerate false
```

### Monitor Mining

```bash
# Check if mining is active
~/monetarium/monetarium-ctl getmininginfo

# Check hashrate
~/monetarium/monetarium-ctl gethashespersec
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

Add these options to `~/Library/"Application Support"/Monetarium-wallet/monetarium-wallet.conf`:

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

For automated staking, the wallet needs to unlock automatically. Add to `~/Library/"Application Support"/Monetarium-wallet/monetarium-wallet.conf`:

```ini
; WARNING: Reduces security - only use on dedicated staking machines
; Private passphrase for automatic wallet unlock
pass=YourWalletPassphrase
```

> **Security Warning**: Storing the passphrase in config reduces security. Only use this on dedicated staking machines or wallets with limited balances.

### Staking Workflow

#### Step 1: Generate Staking Address

On your staking wallet:

```bash
~/monetarium/monetarium-ctl --wallet getnewaddress
```

Save this address (e.g., `MsStakingAddress...`)

#### Step 2: Send VAR from Mining Node

If mining on a separate machine, send VAR to your staking wallet:

```bash
# On mining node's wallet
~/monetarium/monetarium-ctl --wallet sendtoaddress "MsStakingAddress..." 100
```

#### Step 3: Start Staking Wallet

```bash
~/monetarium/monetarium-wallet
```

The wallet will automatically:
1. Monitor your balance
2. Purchase tickets when funds are available
3. Vote on blocks when tickets are selected
4. Receive staking rewards

### Monitor Staking

```bash
# Check ticket status
~/monetarium/monetarium-ctl --wallet getstakeinfo

# List your tickets
~/monetarium/monetarium-ctl --wallet gettickets true

# Check voting status
~/monetarium/monetarium-ctl --wallet walletinfo
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

```bash
# Check if process is running
pgrep -l monetarium-node

# Check sync status
~/monetarium/monetarium-ctl getblockcount

# Compare with network (ask peers)
~/monetarium/monetarium-ctl getblockchaininfo
```

### Verify Peer Connections

```bash
# List connected peers
~/monetarium/monetarium-ctl getpeerinfo

# Check connection count
~/monetarium/monetarium-ctl getconnectioncount
```

### Verify Wallet Connection

```bash
# Check wallet is connected to node
~/monetarium/monetarium-ctl --wallet getinfo

# Check balance
~/monetarium/monetarium-ctl --wallet getbalance
```

### Common Issues

#### "Connection refused" when using monetarium-ctl

**Cause**: monetarium-node is not running or RPC is misconfigured.

**Solution**:
```bash
# Check if node is running
pgrep monetarium-node

# Verify RPC credentials match in:
# ~/Library/"Application Support"/Monetarium/monetarium.conf
# ~/Library/"Application Support"/Monetarium-ctl/monetarium-ctl.conf
```

#### Wallet won't start - "unable to open database"

**Cause**: Wallet database is corrupted or wallet is already running.

**Solution**:
```bash
# Check if already running
pgrep monetarium-wallet

# Kill existing process
pkill monetarium-wallet

# Try again
~/monetarium/monetarium-wallet
```

#### No peers connecting

**Cause**: Firewall blocking connections or no seed nodes configured.

**Solution**:
```bash
# Ensure seed node is configured
~/monetarium/monetarium-node --addpeer=176.113.164.216:9108

# Check firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --listapps
```

#### Sync is very slow

**Cause**: Limited peer connections or network issues.

**Solution**:
- Ensure port 9108 is forwarded in your router
- Add more peers if available
- Check internet connection stability

### Log File Locations

| Service | Log Path |
|---------|----------|
| monetarium-node | `~/Library/"Application Support"/Monetarium/logs/mainnet/monetarium.log` |
| monetarium-wallet | `~/Library/"Application Support"/Monetarium-wallet/logs/mainnet/monetarium-wallet.log` |
| launchd (node) | `~/Library/"Application Support"/Monetarium/logs/launchd-stdout.log` |
| launchd (wallet) | `~/Library/"Application Support"/Monetarium-wallet/logs/launchd-stdout.log` |

### View Logs

```bash
# View node log (last 100 lines)
tail -100 ~/Library/"Application Support"/Monetarium/logs/mainnet/monetarium.log

# Follow node log in real-time
tail -f ~/Library/"Application Support"/Monetarium/logs/mainnet/monetarium.log

# View wallet log
tail -f ~/Library/"Application Support"/Monetarium-wallet/logs/mainnet/monetarium-wallet.log
```

---

## Quick Reference

### Essential Commands

```bash
# Start node
~/monetarium/monetarium-node --addpeer=176.113.164.216:9108

# Start wallet
~/monetarium/monetarium-wallet

# Check balance
~/monetarium/monetarium-ctl --wallet getbalance

# Get new address
~/monetarium/monetarium-ctl --wallet getnewaddress

# Check sync status
~/monetarium/monetarium-ctl getblockcount

# List peers
~/monetarium/monetarium-ctl getpeerinfo
```

### Mining Commands

```bash
# Check mining status
~/monetarium/monetarium-ctl getmininginfo

# Check hashrate
~/monetarium/monetarium-ctl gethashespersec

# Check available CPU cores
sysctl -n hw.ncpu
```

### Staking Commands

```bash
# Check stake info
~/monetarium/monetarium-ctl --wallet getstakeinfo

# List tickets
~/monetarium/monetarium-ctl --wallet gettickets true

# Check wallet info
~/monetarium/monetarium-ctl --wallet walletinfo
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
| `~/monetarium/` | Binary installation |
| `~/Library/"Application Support"/Monetarium/` | Node data & config |
| `~/Library/"Application Support"/Monetarium-wallet/` | Wallet data & config |
| `~/Library/"Application Support"/Monetarium-ctl/` | CLI config |

---

## Support

For additional help:
- GitHub Issues: https://github.com/monetarium/issues
- Community Discord: [Link TBD]
