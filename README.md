# FWB Migration Contracts

Smart contracts for the migration of $FWB tokens from ETH mainnet to Base. 

## Overview

The $FWB migration is distinct from a standard token bridging process in three ways:

1. For each 1 $FWB token on ETH mainnet a user migrates, they will receive 9 $FWB tokens on Base.
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

# Project Structure

## Contracts

Solidity smart contracts are located in the `./src/` directory:

- **`IFWBToken.sol`**: Interface for the FWB Token, defining the necessary methods and standards.
- **`MigrationDistributor.sol`**: Manages the distribution of FWB tokens during the migration process.
- **`MigrationManager.sol`**: Oversees and manages the entire migration process.

## Deployment Scripts

Deployment scripts are found in the `./script/` folder. These Solidity scripts are used to deploy the contracts using `forge script` (ex. `forge script script/MigrationManager.s.sol:Deploy`):

- **`MigrationDistributor.s.sol`**: Script to deploy the `MigrationDistributor` contract.
- **`MigrationManager.s.sol`**: Script to deploy the `MigrationManager` contract.
- **`TestToken.s.sol`**: Script to deploy the `TestToken` for testing purposes.

Additionally, shell scripts for deployment are located in the `./deploy/` folder:

- **`dev.sh`**: Used to deploy the contracts in a development environment.

To deploy the contracts locally, follow these steps:
1. Copy `./.env.example` to `./.env` in the project root.
2. Replace deployer's private key and other necessary variables to the `.env` file:
3. Start `anvil`
4. Run each of the deployment scripts individually, or by running `./dev.sh` in the deploy directory

