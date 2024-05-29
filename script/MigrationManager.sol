//     // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.20;

// import "forge-std/Script.sol";

// import { MigrationManager } from "../src/MigrationManager.sol";

// contract Deploy is Script {
//     function setUp() public {}

//     function run() public returns (address marketPlace) {
//         uint deployer =  vm.envUint(vm.envString("DEPLOYER_PRIVATE_KEY"));
//         vm.startBroadcast(deployer); 
//         marketPlace = deploy();
//         vm.stopBroadcast();
//         return (marketPlace);
//     }

//     function deploy() public returns (address) {
//         /// Deploy MarketPlace
//         return address(new MigrationManager());
//     }
// }
