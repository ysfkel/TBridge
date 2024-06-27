    // SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import "forge-std/Script.sol";

import { TestToken } from "../test/TestToken.sol";

contract Deploy is Script {
    function setUp() public {}

    function run() public returns (address test_token) {
        uint deployerPrivateKey =  vm.envUint("DEPLOYER_PRIVATE_KEY");
        address deployerAccount = vm.addr(deployerPrivateKey);
        console.log('MY ACCOUNT ', deployerAccount);
        vm.startBroadcast(deployerPrivateKey); 
        test_token = deploy(deployerAccount);
        vm.stopBroadcast();
        return (test_token);
    }

    function deploy(address account) public returns (address) {
        /// Deploy Test token
        TestToken token = new TestToken();
        token.mint(account, 1000000 ether);
        console.log('==== token ',address(token));
        uint256 balance = token.balanceOf(account);
        console.log('==== account ',account);
        console.log('==== balance ',balance);
        uint256 totalSupply = token.totalSupply();
        console.log('==== totalSupply ',totalSupply);
        return address(new TestToken());
    }
}
