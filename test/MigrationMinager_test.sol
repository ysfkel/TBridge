// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import { MigrationManager } from "../src/MigrationManager.sol";
import { IFWBToken } from "../src/IFWBToken.sol";
import { TestToken } from "./TestToken.sol";

contract MigrationManagerTest is Test {
    event Deposit(address indexed account, address indexed recipient, uint256 amount);
    
    MigrationManager mm;
    TestToken fwb;
    address USER1 =  makeAddr("USER1");

    function setUp() public {
        fwb = new TestToken();
        fwb.mint(msg.sender, 1000 ether);
        mm = new MigrationManager(address(fwb));
    }

    function test_constructor() view public  {
        assertEq(address(mm.migrationToken()), address(fwb));
    } 

    function test_deposit_succeeds()  public  {
        vm.startPrank(msg.sender);
        fwb.approve(address(mm), 100 ether);
        vm.expectEmit(true, true, true, true);
        emit Deposit(msg.sender, msg.sender, 100 ether);
        mm.deposit(100 ether);
        assertEq(mm.deposits(msg.sender), 100 ether);
        assertEq(mm.depositsTo(msg.sender,msg.sender), 100 ether);
        assertEq(fwb.balanceOf(address(mm)), 100 ether);
        vm.stopPrank();
    } 

    function test_deposit_to_succeeds()  public  {
        vm.startPrank(msg.sender);
        fwb.approve(address(mm), 100 ether);
        vm.expectEmit(true, true, true, true);
        emit Deposit(msg.sender, USER1, 100 ether);
        mm.depositTo(100 ether, USER1);
        assertEq(mm.deposits(msg.sender), 100 ether);
        assertEq(mm.depositsTo(msg.sender, USER1), 100 ether);
        assertEq(fwb.balanceOf(address(mm)), 100 ether);
        vm.stopPrank();
    } 

    function test_multiple_deposit_succeeds()  public  {
        vm.startPrank(msg.sender);
        fwb.mint(msg.sender, 1000 ether);
        fwb.approve(address(mm), 300 ether);
        mm.deposit(100 ether);
        mm.deposit(100 ether);
        mm.deposit(100 ether);
        assertEq(mm.deposits(msg.sender), 300 ether);
        assertEq(mm.depositsTo(msg.sender,msg.sender), 300 ether);
        assertEq(fwb.balanceOf(address(mm)), 300 ether);
        vm.stopPrank();
    } 

    function testFuzz_test_deposit_succeeds(uint256 amount) public {
        vm.startPrank(msg.sender);
        TestToken _fwb = new TestToken();
        _fwb.mint(msg.sender, amount);
        MigrationManager _mm = new MigrationManager(address(_fwb));
        _fwb.approve(address(_mm), amount);
        _mm.deposit(amount);
        assertEq(_mm.deposits(msg.sender), amount);
        assertEq(_mm.depositsTo(msg.sender,msg.sender), amount);
        assertEq(_fwb.balanceOf(address(_mm)), amount);
        vm.stopPrank();
    }
}
