# Monetarium Linux Installation Guide

This guide provides step-by-step instructions for installing and running a Monetarium node and wallet on Linux (Ubuntu).

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

- Installing the Monetarium node (`node`) to participate in the network
- Setting up the wallet (`wallet`) to manage your coins
- Configuring your network for optimal connectivity

---

## System Requirements

| Requirement | Minimum |
|-------------|---------|
| **Linux Version** | Ubuntu 20.04 LTS or later (Debian-based) |
| **Disk Space** | 50 GB free (for blockchain data) |
| **RAM** | 4 GB |
| **Internet** | Stable broadband connection |
| **Architecture** | x86_64 (amd64) or arm64 |

---

## Download Binaries

### Step 1: Identify Your Architecture

Open Terminal and run:

```bash
uname -m
```

- `x86_64` = Intel/AMD 64-bit → download **amd64** binaries
- `aarch64` = ARM 64-bit (Raspberry Pi 4, etc.) → download **arm64** binaries

### Step 2: Download from GitHub

Visit the release pages:
- [node](https://github.com/monetarium/monetarium/releases)
- [wallet](https://github.com/monetarium/monetarium/releases)
- [ctl](https://github.com/monetarium/monetarium/releases)

Download the following files for your architecture:

**For x86_64 (amd64):**
- `node-linux-amd64`
- `wallet-linux-amd64`
- `ctl-linux-amd64`

**For ARM64 (aarch64):**
- `node-linux-arm64`
- `wallet-linux-arm64`
- `ctl-linux-arm64`

### Step 3: Verify Downloads (Optional)

If SHA256 checksums are provided, verify your downloads:

```bash
sha256sum node-linux-*
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
mv ~/Downloads/node-linux-* ~/monetarium/node
mv ~/Downloads/wallet-linux-* ~/monetarium/wallet
mv ~/Downloads/ctl-linux-* ~/monetarium/ctl
```

### Step 3: Make Binaries Executable

```bash
chmod +x ~/monetarium/node
chmod +x ~/monetarium/wallet
chmod +x ~/monetarium/ctl
```

### Step 4: Add to PATH (Optional)

To run commands from any directory, add to your shell profile:

```bash
echo 'export PATH="$HOME/monetarium:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

For Zsh users, use `~/.zshrc` instead.

---

## Running the Node (node)

The node (`node`) connects to the Monetarium network and maintains a copy of the blockchain.

### First Run

```bash
~/monetarium/node --addpeer=176.113.164.216:9108
```

On first run, node will:
- Create configuration directory at `~/.dcrd/`
- Generate RPC credentials in `~/.dcrd/dcrd.conf`
- Create TLS certificates for secure RPC communication
- Begin syncing the blockchain

### Configuration File

The main configuration file is located at `~/.dcrd/dcrd.conf`. Key options:

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
| `~/.dcrd/dcrd.conf` | Configuration file |
| `~/.dcrd/data/mainnet/` | Blockchain database |
| `~/.dcrd/logs/mainnet/` | Log files |
| `~/.dcrd/rpc.cert` | TLS certificate |

---

## Running the Wallet (wallet)

The wallet (`wallet`) manages your VAR and SKA coins.

### Prerequisites

- The node (`node`) must be running
- Copy the RPC certificate from node

### Step 1: Copy RPC Certificate

```bash
mkdir -p ~/.dcrwallet
cp ~/.dcrd/rpc.cert ~/.dcrwallet/
```

### Step 2: Create Wallet

```bash
~/monetarium/wallet --create
```

You will be prompted to:
1. Enter a **private passphrase** (encrypts your wallet - REMEMBER THIS!)
2. Optionally enter a **public passphrase** (for watching-only access)
3. Choose whether to add encryption for public data
4. **IMPORTANT**: Write down your **33-word seed phrase** and store it securely

> **WARNING**: Your seed phrase is the ONLY way to recover your wallet. Store it offline in a secure location. Never share it with anyone.

### Step 3: Start the Wallet

```bash
~/monetarium/wallet
```

### Configuration File

The wallet configuration is at `~/.dcrwallet/dcrwallet.conf`:

```ini
; Connect to local dcrd
rpcconnect=127.0.0.1:9109

; Use dcrd's RPC credentials
username=your_rpc_user
password=your_rpc_password

; Path to dcrd's certificate
cafile=~/.dcrwallet/rpc.cert
```

### Data Directories

| Path | Contents |
|------|----------|
| `~/.dcrwallet/dcrwallet.conf` | Configuration file |
| `~/.dcrwallet/mainnet/wallet.db` | Wallet database |
| `~/.dcrwallet/logs/mainnet/` | Log files |

---

## Using ctl

`ctl` is the command-line interface for interacting with the node and wallet.

### Basic Setup

Create a configuration file at `~/.dcrctl/dcrctl.conf`:

```bash
mkdir -p ~/.dcrctl
```

```ini
rpcuser=your_rpc_user
rpcpass=your_rpc_password
rpcserver=127.0.0.1:9109
rpccert=~/.dcrd/rpc.cert
```

### Node Commands

```bash
# Check node sync status
~/monetarium/ctl getblockcount

# Get network info
~/monetarium/ctl getnetworkinfo

# List connected peers
~/monetarium/ctl getpeerinfo

# Get blockchain info
~/monetarium/ctl getblockchaininfo
```

### Wallet Commands

Add `--wallet` flag to interact with the wallet:

```bash
# Get wallet balance
~/monetarium/ctl --wallet getbalance

# Generate new address
~/monetarium/ctl --wallet getnewaddress

# List transactions
~/monetarium/ctl --wallet listtransactions

# Send coins (unlocks wallet temporarily)
~/monetarium/ctl --wallet sendtoaddress "MsAddress..." 1.0
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

### UFW Firewall Configuration (Ubuntu)

#### Check Firewall Status

```bash
sudo ufw status
```

#### Allow Monetarium P2P Port

```bash
sudo ufw allow 9108/tcp comment 'Monetarium P2P'
```

#### Enable Firewall (if not already enabled)

```bash
sudo ufw enable
```

#### Verify Rules

```bash
sudo ufw status numbered
```

### iptables Configuration (Alternative)

If using iptables directly:

```bash
# Allow incoming connections on port 9108
sudo iptables -A INPUT -p tcp --dport 9108 -j ACCEPT

# Save rules (Ubuntu)
sudo netfilter-persistent save
```

### Router Port Forwarding

> **Note**: You may need to order a static IP from your ISP to allow incoming connections.

In most cases your global IP will point to your router, which will do the port forwarding to your node's local IP.

#### Step 1: Find Your Local IP

```bash
ip addr show | grep "inet " | grep -v 127.0.0.1
```

Or:

```bash
hostname -I
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
| Internal IP | Your machine's IP (e.g., 192.168.1.100) |

#### Step 4: Set Static IP (Recommended)

To prevent your IP from changing:

1. In router settings, find **DHCP Reservation** or **Address Reservation**
2. Add your machine's MAC address with a fixed IP
3. Or configure a static IP using netplan (Ubuntu 18.04+):

Edit `/etc/netplan/01-netcfg.yaml`:

```yaml
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
```

Apply changes:

```bash
sudo netplan apply
```

#### Step 5: Verify Port is Open

After configuration, verify the port is accessible:

```bash
# From another network or use online port checker
nc -zv your.public.ip 9108
```

Or use an online port checker at https://www.yougetsignal.com/tools/open-ports/

---

## Running as Background Service

Use `systemd` to run Monetarium services automatically.

### node Service

Create the service file:

```bash
sudo tee /etc/systemd/system/monetarium-node.service << 'EOF'
[Unit]
Description=Monetarium Node
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=YOUR_USERNAME
ExecStart=/home/YOUR_USERNAME/monetarium/node --addpeer=176.113.164.216:9108
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
```

**Important**: Replace `YOUR_USERNAME` with your actual Linux username:

```bash
sudo sed -i "s/YOUR_USERNAME/$USER/g" /etc/systemd/system/monetarium-node.service
```

### wallet Service

Create the wallet service (starts after node):

```bash
sudo tee /etc/systemd/system/monetarium-wallet.service << 'EOF'
[Unit]
Description=Monetarium Wallet
After=network-online.target monetarium-node.service
Wants=network-online.target
Requires=monetarium-node.service

[Service]
Type=simple
User=YOUR_USERNAME
ExecStart=/home/YOUR_USERNAME/monetarium/wallet
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo sed -i "s/YOUR_USERNAME/$USER/g" /etc/systemd/system/monetarium-wallet.service
```

### Service Management

```bash
# Reload systemd configuration
sudo systemctl daemon-reload

# Enable services to start on boot
sudo systemctl enable monetarium-node
sudo systemctl enable monetarium-wallet

# Start node
sudo systemctl start monetarium-node

# Start wallet
sudo systemctl start monetarium-wallet

# Stop node
sudo systemctl stop monetarium-node

# Stop wallet
sudo systemctl stop monetarium-wallet

# Check status
sudo systemctl status monetarium-node
sudo systemctl status monetarium-wallet

# View logs
journalctl -u monetarium-node -f
journalctl -u monetarium-wallet -f
```

### Disable Auto-Start

To prevent services from starting at boot:

```bash
sudo systemctl disable monetarium-node
sudo systemctl disable monetarium-wallet
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
~/monetarium/node --addpeer=176.113.164.216:9108
```

#### Method 2: Configuration File

Add to `~/.dcrd/dcrd.conf`:

```ini
addpeer=176.113.164.216:9108
```

#### Method 3: Connect-Only Mode

To connect ONLY to specific peers (no other connections):

```bash
~/monetarium/node --connect=176.113.164.216:9108
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

```bash
# Stop dcrwallet first
sudo systemctl stop monetarium-wallet

# Copy wallet file
cp ~/.dcrwallet/mainnet/wallet.db ~/backup/wallet.db.backup

# Restart dcrwallet
sudo systemctl start monetarium-wallet
```

### Recover From Seed Phrase

If you need to restore your wallet on a new machine:

```bash
# Create new wallet with existing seed
~/monetarium/wallet --create
```

When prompted:
1. Enter a new private passphrase
2. Choose **"yes"** when asked to restore from seed
3. Enter your 33-word seed phrase
4. Enter the original wallet creation date (or skip to scan all blocks)

### Recover From Wallet File

```bash
# Stop wallet if running
sudo systemctl stop monetarium-wallet

# Restore wallet file
cp ~/backup/wallet.db.backup ~/.dcrwallet/mainnet/wallet.db

# Start wallet
sudo systemctl start monetarium-wallet
```

---

## CPU Mining Configuration

Monetarium uses CPU mining with the Blake3 algorithm. Here's how to configure your node for mining.

### Check Available CPU Cores

```bash
nproc
```

Or for detailed info:

```bash
lscpu | grep "^CPU(s):"
```

This shows the total number of CPU threads available.

### Enable Mining in Configuration

Add these options to `~/.dcrd/dcrd.conf`:

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

```bash
~/monetarium/ctl --wallet getnewaddress
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

```bash
# If running as service
sudo systemctl restart monetarium-node

# Or manually
~/monetarium/node --addpeer=176.113.164.216:9108
```

### Monitor Mining

```bash
# Check if mining is active
~/monetarium/ctl getmininginfo

# Check hashrate
~/monetarium/ctl gethashespersec
```

### Mining Tips

- **Start conservative**: Begin with fewer threads and increase if system remains responsive
- **Monitor temperature**: CPU mining generates heat; ensure adequate cooling (`sensors` command if lm-sensors installed)
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

Add these options to `~/.dcrwallet/dcrwallet.conf`:

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

For automated staking, the wallet needs to unlock automatically. Add to `~/.dcrwallet/dcrwallet.conf`:

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
~/monetarium/ctl --wallet getnewaddress
```

Save this address (e.g., `MsStakingAddress...`)

#### Step 2: Send VAR from Mining Node

If mining on a separate machine, send VAR to your staking wallet:

```bash
# On mining node's wallet
~/monetarium/ctl --wallet sendtoaddress "MsStakingAddress..." 100
```

#### Step 3: Start Staking Wallet

```bash
~/monetarium/wallet
```

The wallet will automatically:
1. Monitor your balance
2. Purchase tickets when funds are available
3. Vote on blocks when tickets are selected
4. Receive staking rewards

### Monitor Staking

```bash
# Check ticket status
~/monetarium/ctl --wallet getstakeinfo

# List your tickets
~/monetarium/ctl --wallet gettickets true

# Check voting status
~/monetarium/ctl --wallet walletinfo
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
pgrep -l node

# Check sync status
~/monetarium/ctl getblockcount

# Compare with network (ask peers)
~/monetarium/ctl getblockchaininfo
```

### Verify Peer Connections

```bash
# List connected peers
~/monetarium/ctl getpeerinfo

# Check connection count
~/monetarium/ctl getconnectioncount
```

### Verify Wallet Connection

```bash
# Check wallet is connected to node
~/monetarium/ctl --wallet getinfo

# Check balance
~/monetarium/ctl --wallet getbalance
```

### Common Issues

#### "Connection refused" when using ctl

**Cause**: node is not running or RPC is misconfigured.

**Solution**:
```bash
# Check if node is running
pgrep node

# Verify RPC credentials match in:
# ~/.dcrd/dcrd.conf
# ~/.dcrctl/dcrctl.conf
```

#### Wallet won't start - "unable to open database"

**Cause**: Wallet database is corrupted or wallet is already running.

**Solution**:
```bash
# Check if already running
pgrep wallet

# Kill existing process
pkill wallet

# Try again
~/monetarium/wallet
```

#### No peers connecting

**Cause**: Firewall blocking connections or no seed nodes configured.

**Solution**:
```bash
# Ensure seed node is configured
~/monetarium/node --addpeer=176.113.164.216:9108

# Check firewall
sudo ufw status
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
| node | `~/.dcrd/logs/mainnet/dcrd.log` |
| wallet | `~/.dcrwallet/logs/mainnet/dcrwallet.log` |
| systemd (node) | `journalctl -u monetarium-node` |
| systemd (wallet) | `journalctl -u monetarium-wallet` |

### View Logs

```bash
# View dcrd log (last 100 lines)
tail -100 ~/.dcrd/logs/mainnet/dcrd.log

# Follow dcrd log in real-time
tail -f ~/.dcrd/logs/mainnet/dcrd.log

# View wallet log
tail -f ~/.dcrwallet/logs/mainnet/dcrwallet.log

# View systemd logs in real-time
journalctl -u monetarium-node -f
journalctl -u monetarium-wallet -f
```

---

## Quick Reference

### Essential Commands

```bash
# Start node
~/monetarium/node --addpeer=176.113.164.216:9108

# Start wallet
~/monetarium/wallet

# Check balance
~/monetarium/ctl --wallet getbalance

# Get new address
~/monetarium/ctl --wallet getnewaddress

# Check sync status
~/monetarium/ctl getblockcount

# List peers
~/monetarium/ctl getpeerinfo
```

### Mining Commands

```bash
# Check mining status
~/monetarium/ctl getmininginfo

# Check hashrate
~/monetarium/ctl gethashespersec

# Check available CPU threads
nproc
```

### Staking Commands

```bash
# Check stake info
~/monetarium/ctl --wallet getstakeinfo

# List tickets
~/monetarium/ctl --wallet gettickets true

# Check wallet info
~/monetarium/ctl --wallet walletinfo
```

### Service Commands

```bash
# Start services
sudo systemctl start monetarium-node
sudo systemctl start monetarium-wallet

# Stop services
sudo systemctl stop monetarium-node
sudo systemctl stop monetarium-wallet

# Restart services
sudo systemctl restart monetarium-node
sudo systemctl restart monetarium-wallet

# Check status
sudo systemctl status monetarium-node
sudo systemctl status monetarium-wallet

# Enable auto-start on boot
sudo systemctl enable monetarium-node
sudo systemctl enable monetarium-wallet

# View logs
journalctl -u monetarium-node -f
journalctl -u monetarium-wallet -f
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
| `~/.dcrd/` | Node data & config |
| `~/.dcrwallet/` | Wallet data & config |
| `~/.dcrctl/` | CLI config |

---

## Support

For additional help:
- GitHub Issues: https://github.com/monetarium/issues
- Community Discord: [Link TBD]
