// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/Test.sol";
import { Deploy } from "../script/DeployMigrationManager.s.sol";
import { MigrationManager } from "../src/MigrationManager.sol";
import { TestToken } from "./TestToken.sol";

contract MigrationManagerDeployTest is Test {
    Deploy deployScript; 
     address _fwbToken;

    function setUp() public {
        deployScript = new Deploy(); 
    }

    function testDeployment() public {
       // Set environment variables 
       _fwbToken = address(new TestToken()); 
       vm.setEnv("FWB_TOKEN_ETHEREUM", vm.toString(_fwbToken)); 
       // Execute the deploy script
       deployScript.setUp();
       address migrationManager = deployScript.run();
       MigrationManager manager = MigrationManager(migrationManager);
       assertEq(address(manager.fwbToken()), address(_fwbToken)); 
    }
}