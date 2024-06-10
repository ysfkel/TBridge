    // SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";

import { MigrationManager } from "../src/MigrationManager.sol";

contract Deploy is Script {
    function setUp() public {}

    function run() public returns (address migration_manager) {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address fwbToken = vm.envAddress("ETHEREUM_FWB_TOKEN");
        vm.startBroadcast(deployerPrivateKey); 
        migration_manager = deploy(fwbToken);
        vm.stopBroadcast();
        return (fwbToken);
    }

    function deploy(address token) public returns (address) {
        return address(new MigrationManager(token));
    }
}
