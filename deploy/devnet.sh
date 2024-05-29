#!/bin/bash

source .env
# Deploy MarketPlace.s.sol
echo "Deploying MarketPlace.s.sol..."
DEPLOYER_PRIVATE_KEY=DEV_PRIVATE_KEY forge script script/MarketPlace.s.sol:Deploy  --rpc-url http://127.0.0.1:8545 --broadcast

if [ $? -ne 0 ]; then
    echo "Failed to deploy MarketPlace.s.sol"
    exit 1
fi

# Deploy RewardPoint.s.sol
echo "Deploying RewardPoint.s.sol..."
DEPLOYER_PRIVATE_KEY=DEV_PRIVATE_KEY SIGNER_PRIVATE_KEY=DEV_SIGNER_PRIVATE_KEY forge script script/RewardPoint.s.sol:Deploy --rpc-url http://127.0.0.1:8545 --broadcast

if [ $? -ne 0 ]; then
    echo "Failed to deploy RewardPoint.s.sol"
    exit 1
fi

# Deploy Token.sol
echo "Deploying Token.s.sol..."
DEPLOYER_PRIVATE_KEY=DEV_PRIVATE_KEY forge script script/Token.s.sol:Deploy --rpc-url http://127.0.0.1:8545 --broadcast

if [ $? -ne 0 ]; then
    echo "Failed to deploy Token.s.sol"
    exit 1
fi

echo "Deployment completed successfully!"