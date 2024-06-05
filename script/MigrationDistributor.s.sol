    // SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";

import { MigrationDistributor } from "../src/MigrationDistributor.sol";

contract Deploy is Script {
    function setUp() public {}

    function run() public returns (address migration_distributor) {
        uint256 deployerPrivateKey = vm.envUint("DEV_PRIVATE_KEY");      
        vm.startBroadcast(deployerPrivateKey); 
        migration_distributor = deploy();
        vm.stopBroadcast();
        return (migration_distributor);
    }

    function deploy() public returns (address) { 
        uint256 _conversionRate = vm.envUint("MIGRATION_DISTRIBUTOR_CONVERSION_RATE");
        uint256 _transferDelay = vm.envUint("MIGRATION_DISTRIBUTOR_TRANSFER_DELAY");
        address _baseToken = vm.addr(vm.envUint("TEST_TOKEN"));
        address _migrationRecorder = vm.addr(vm.envUint("MIGRATION_DISTRIBUTOR_RECORDER"));
        address _migrationProcessor = vm.addr(vm.envUint("MIGRATION_DISTRIBUTOR_PROCESSOR"));

        return address(new MigrationDistributor(
            _conversionRate,
            _transferDelay,
            _baseToken,
            _migrationRecorder,
            _migrationProcessor
        ));
    }
}
