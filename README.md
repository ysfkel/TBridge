# FWB Migration Contracts

Smart contracts for the migration of $FWB tokens from ETH mainnet to Base. 

## Overview

The $FWB migration is distinct from a standard token bridging process in three ways:

1. For each 1 $FWB token on ETH mainnet a user migrates, they will receive 10 $FWB tokens on Base.
2. Once $FWB is deposited to the Migration Manager contract on ETH mainnet, they cannot be withdrawn.
3. The owner of the Migration Manager contract can burn $FWB tokens that are locked in the contract.

These contracts are intended to be used with an off-chain process to complete the transfer of Base $FWB whenever a user deposits mainnet $FWB to the Migration Manager contract. The Migration Distributor contract defines the two roles the off-chain process will implement.

1. The Migration Recorder: The address responsible for writing deposit information to the Migration Distributor contract on Base.
2. The Migration Processor: The address responsible for transferring FWB tokens on Base for each recorded deposit, and then marking those deposits as processed.


## Development

### Installation

This repository uses [Foundry](https://github.com/foundry-rs/foundry) to compile and test contracts.

Install dependencies:

```
forge install
```

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```
