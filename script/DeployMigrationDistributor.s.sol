    // SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import "forge-std/Script.sol";

import { MigrationDistributor } from "../src/MigrationDistributor.sol";

contract Deploy is Script {
    function setUp() public {}

    function run() public returns (address migration_distributor) {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");      
        vm.startBroadcast(deployerPrivateKey); 
        migration_distributor = deploy();
        vm.stopBroadcast();
        return (migration_distributor);
    }

    function deploy() private returns (address) { 
        uint256 _conversionRate = vm.envUint("MIGRATION_DISTRIBUTOR_CONVERSION_RATE");
        uint256 _transferDelay = vm.envUint("MIGRATION_DISTRIBUTOR_TRANSFER_DELAY");
        address _fwbToken = vm.envAddress("FWB_TOKEN_BASE");
        uint256 _migrationRecorderUint = vm.envUint("MIGRATION_DISTRIBUTOR_RECORDER");
        uint256 _migrationProcessorUint = vm.envUint("MIGRATION_DISTRIBUTOR_PROCESSOR");

        address _migrationRecorder = vm.addr(_migrationRecorderUint);
        address _migrationProcessor = vm.addr(_migrationProcessorUint);

        return address(new MigrationDistributor(
            _conversionRate,
            _transferDelay,
            _fwbToken,
            _migrationRecorder,
            _migrationProcessor
        ));
    }
}
