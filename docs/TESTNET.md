# Monetarium Testnet Guide

This guide covers testnet-specific configuration. For full installation instructions, see:
- [macOS Installation](MACOS_INSTALLATION.md)
- [Windows Installation](WINDOWS_INSTALLATION.md)
- [Linux Installation](LINUX_INSTALLATION.md)

Testnet is for development and testing with coins that have no real value.

## Quick Start

Add `--testnet` flag to any command:

```bash
monetarium-node --testnet
monetarium-wallet --testnet
monetarium-ctl --testnet getblockcount
```

## Key Differences

| Setting | Mainnet | Testnet |
|---------|---------|---------|
| Command Flag | (none) | `--testnet` |
| P2P Port | 9108 | 19108 |
| Node RPC | 9109 | 19109 |
| Wallet JSON-RPC | 9110 | 19110 |
| Wallet gRPC | 9111 | 19111 |
| Address Prefix | `Ms` | `Ts` |
| Block Time | 5 min | 2 min |
| Halving Interval | ~4 years | ~1 month |
| Data Subfolder | `mainnet/` | `testnet3/` |
| SKA-1 Emission | Block 4096 | Block 800 |
| SKA-2 Emission | Block 150,000 | Block 1,000 |

## Data Directories

Same base paths as mainnet, different subfolder:

| OS | Testnet Data Path |
|----|-------------------|
| macOS | `~/Library/Application Support/Monetarium/testnet3/` |
| Windows | `%LOCALAPPDATA%\Monetarium\testnet3\` |
| Linux | `~/.monetarium/testnet3/` |

## Configuration Files

Configuration files are in the same locations as mainnet. Add `testnet=1` to enable testnet mode.

### Node (monetarium-node.conf)

```ini
testnet=1
rpcuser=your_rpc_user
rpcpass=your_rpc_password
notls=1
```

### Wallet (monetarium-wallet.conf)

The wallet connects to the **node's RPC** (port 19109):

```ini
testnet=1
rpcconnect=127.0.0.1:19109
username=your_rpc_user
password=your_rpc_password
noclienttls=1
```

### Ctl (monetarium-ctl.conf)

By default, ctl connects to the **node** (port 19109). Use `--wallet` flag to connect to the **wallet** (port 19110):

```ini
testnet=1
rpcuser=your_rpc_user
rpcpass=your_rpc_password
notls=1
```

## Command Examples

```bash
# Start node in testnet mode
monetarium-node --testnet

# Start wallet (connects to testnet node automatically)
monetarium-wallet --testnet

# Query node
monetarium-ctl --testnet getblockcount
monetarium-ctl --testnet getinfo

# Query wallet (note: --wallet flag)
monetarium-ctl --testnet --wallet getbalance
monetarium-ctl --testnet --wallet listunspent
```

## Network Parameters

Testnet has accelerated parameters for faster testing:

- **Block time**: 2 minutes (vs 5 minutes mainnet)
- **Difficulty adjustment**: Every 144 blocks (~5 hours)
- **Coinbase maturity**: 16 blocks (~32 minutes)
- **Ticket maturity**: 8 blocks (~16 minutes)
- **SKA emissions**: Earlier blocks for testing dual-coin functionality

## Seed Nodes

Testnet seed nodes (if available):

```
testnet-seed.monetarium.io
```

Check project documentation for current testnet seed availability.

## Getting Testnet Coins

1. Mine on testnet (much easier difficulty)
2. Request from testnet faucet (if available)
3. Ask in project community channels
