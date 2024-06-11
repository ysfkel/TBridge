#!/bin/bash

source .env

echo "Deploying TestToken.sol..."
DEPLOY_OUTPUT=$(forge script script/TestToken.s.sol:Deploy --rpc-url http://127.0.0.1:8545 --broadcast)

if [ $? -ne 0 ]; then
    echo "Failed to deploy TestToken.sol"
    exit 1
fi

FWB_TOKEN_ETHEREUM=$(echo "$DEPLOY_OUTPUT" | grep -Eo '0x[a-fA-F0-9]{40}' | head -1)

echo "FWB_TOKEN_ETHEREUM DEPLOYED AT: " $FWB_TOKEN_ETHEREUM

DEPLOY_OUTPUT=$(forge script script/TestToken.s.sol:Deploy --rpc-url http://127.0.0.1:8545 --broadcast)

if [ $? -ne 0 ]; then
    echo "Failed to deploy TestToken.sol"
    exit 1
fi

FWB_TOKEN_BASE=$(echo "$DEPLOY_OUTPUT" | grep -Eo '0x[a-fA-F0-9]{40}' | head -1)

echo "FWB_TOKEN_BASE DEPLOYED AT: " $FWB_TOKEN_BASE

# Deploy MigrationManager.sol
echo "Deploying MigrationManager.sol..."
DEPLOY_OUTPUT=$(FWB_TOKEN_ETHEREUM=$FWB_TOKEN_ETHEREUM forge script script/DeployMigrationManager.s.sol:Deploy  --rpc-url http://127.0.0.1:8545 --broadcast)

if [ $? -ne 0 ]; then
    echo "Failed to deploy MigrationManager.sol"
    exit 1
fi

MIGRATION_MANAGER_ADDRESS=$(echo "$DEPLOY_OUTPUT" | grep -Eo '0x[a-fA-F0-9]{40}' | head -1)
echo "MIGRATION MANAGER DEPLOYED AT: " $MIGRATION_MANAGER_ADDRESS

# Deploy MigrationDistributor.sol
echo "Deploying MigrationDistributor.sol..."
DEPLOY_OUTPUT=$(FWB_TOKEN_BASE=$FWB_TOKEN_BASE forge script script/DeployMigrationDistributor.s.sol:Deploy  --rpc-url http://127.0.0.1:8545 --broadcast)

if [ $? -ne 0 ]; then
    echo "Failed to deploy MigrationDistributor.sol"
    exit 1
fi
MIGRATION_DISTRIBUTOR_ADDRESS=$(echo "$DEPLOY_OUTPUT" | grep -Eo '0x[a-fA-F0-9]{40}' | head -1)
echo "MIGRATION DISTRIBUTOR DEPLOYED AT: " $MIGRATION_DISTRIBUTOR_ADDRESS

# Mint 9M tokens to Migration Distributor
cast send $FWB_TOKEN_BASE "mint(address,uint256)" $MIGRATION_DISTRIBUTOR_ADDRESS 9000000000000000000000000 --private-key $DEPLOYER_PRIVATE_KEY --rpc-url http://127.0.0.1:8545
BALANCE=$(cast call $FWB_TOKEN_BASE "balanceOf(address)" $MIGRATION_DISTRIBUTOR_ADDRESS --private-key $DEPLOYER_PRIVATE_KEY --rpc-url http://127.0.0.1:8545)
echo "MIGRATION DISTRIBUTOR BALANCE: " $BALANCE
