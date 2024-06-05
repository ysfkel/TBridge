#!/bin/bash

source .env
# Deploy MigrationManager.s.sol
echo "Deploying MigrationManager.s.sol..."
forge script script/MigrationManager.s.sol:Deploy  --rpc-url http://127.0.0.1:8545 --broadcast 

if [ $? -ne 0 ]; then
    echo "Failed to deploy MigrationManager.s.sol"
    exit 1
fi


Deploy TestToken.sol
echo "Deploying TestToken.s.sol..."
forge script script/TestToken.s.sol:Deploy --rpc-url http://127.0.0.1:8545 --broadcast 

if [ $? -ne 0 ]; then
    echo "Failed to deploy TestToken.s.sol"
    exit 1
fi

echo "Deployment completed successfully!"