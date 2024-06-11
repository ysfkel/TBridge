// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/Test.sol";
import { Deploy } from "../script/DeployMigrationDistributor.s.sol";
import { MigrationDistributor } from "../src/MigrationDistributor.sol";

contract MigrationDistributorDeployTest is Test {
    Deploy deployScript;
    address migrationDistributor;

    function setUp() public {
        deployScript = new Deploy(); 
    }

    function testDeployment() public {
        // Set environment variables
        uint256 conversionRate = 1000;
        uint256 transferDelay = 60;
        address baseToken = 0x1000000000000000000000000000000000000001; // Example address
        address migrationRecorder = 0x2000000000000000000000000000000000000002; // Example address
        address migrationProcessor = 0x3000000000000000000000000000000000000003; // Example address
        uint256 privateKey = 1234567890; // Example private key


        vm.setEnv("MIGRATION_DISTRIBUTOR_CONVERSION_RATE", vm.toString(conversionRate));
        vm.setEnv("MIGRATION_DISTRIBUTOR_TRANSFER_DELAY", vm.toString(transferDelay));
        vm.setEnv("FWB_TOKEN_BASE", vm.toString(baseToken));
        vm.setEnv("MIGRATION_DISTRIBUTOR_RECORDER", vm.toString(migrationRecorder));
        vm.setEnv("MIGRATION_DISTRIBUTOR_PROCESSOR", vm.toString(migrationProcessor));
        vm.setEnv("DEV_PRIVATE_KEY", vm.toString(privateKey));

        // Execute the deploy script
        deployScript.setUp();
        migrationDistributor = deployScript.run();
        //  Verify deployment
        MigrationDistributor distributor = MigrationDistributor(migrationDistributor);
        assertEq(distributor.conversionRate(), conversionRate);
        assertEq(distributor.transferDelay(), transferDelay);
        assertEq(address(distributor.baseToken()), baseToken);
        assertEq(distributor.migrationRecorder(), migrationRecorder);
        assertEq(distributor.migrationProcessor(), migrationProcessor);
    }
}