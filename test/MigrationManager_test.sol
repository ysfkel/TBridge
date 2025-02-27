// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Ownable} from "@openzeppelin/access/Ownable.sol";
import {Test, console} from "forge-std/Test.sol";
import {MigrationManager} from "../src/MigrationManager.sol";
import {IFWBToken} from "../src/IFWBToken.sol";
import {TestToken, TestTokenFailedTransfer} from "./TestToken.sol";

contract MigrationManagerTest is Test {
    event Deposit(uint64 indexed depositId, address indexed account, address indexed recipient, uint256 amount, uint256 timestamp);

    MigrationManager mm;
    TestToken fwb;
    address USER1 = makeAddr("USER1");
    address USER2 = makeAddr("USER2");

    function setUp() public {
        fwb = new TestToken();
        fwb.mint(msg.sender, 1000 ether);
        fwb.mint(USER1, 1000 ether);
        fwb.mint(USER2, 1000 ether);
        mm = new MigrationManager(address(fwb));
    }

    function test_constructor_reverts_with_MigrationManager__ZeroAddressFwbToken() public {
        vm.startPrank(msg.sender);
        vm.expectRevert(MigrationManager.MigrationManager__ZeroAddressFwbToken.selector);
        new MigrationManager(address(0));
        assertEq(address(mm.fwbToken()), address(fwb));
        vm.stopPrank();
    }

    function test_constructor() public view {
        assertEq(address(mm.fwbToken()), address(fwb));
    }

    function test_deposit_to_reverts_with_MigrationManager__ZeroAmount() public {
        vm.startPrank(msg.sender);
        vm.expectRevert(MigrationManager.MigrationManager__ZeroAmount.selector);
        mm.deposit(0 ether); 
        vm.stopPrank();
    }

    function test_deposit_to_reverts_with_MigrationManager__TransferFailed() public {
        MigrationManager _mm;
        uint256 amount = 100 ether;
        // Initializations
        vm.startPrank(msg.sender); 
        _mm = new MigrationManager(address(new TestTokenFailedTransfer()));
        vm.stopPrank(); 
        vm.startPrank(USER1);
        vm.expectRevert(abi.encodeWithSelector(MigrationManager.MigrationManager__TransferFailed.selector, USER1, amount));
        _mm.deposit(amount);
        vm.stopPrank();
    }

    function test_deposit_succeeds() public {
        vm.startPrank(msg.sender);
        fwb.approve(address(mm), 100 ether);
        vm.expectEmit(true, true, true, true); 
        emit Deposit(1, msg.sender, msg.sender, 100 ether, block.timestamp);
        mm.deposit(100 ether);
        MigrationManager.DepositInfo memory depositInfo = mm.getDepositInfo(1);
        assertEq(depositInfo.amount, 100 ether);
        assertEq(depositInfo.recipient, msg.sender);
        assertEq(depositInfo.depositor, msg.sender);
        assertEq(depositInfo.depositId, 1);
        assertEq(depositInfo.timestamp, vm.getBlockTimestamp());
        assertEq(mm.getDepositCount(), 1);
        assertEq(fwb.balanceOf(address(mm)), 100 ether);
        vm.stopPrank();
    }

    function test_deposit_to_reverts_with_MigrationManager__ZeroAddressRecipient() public {
        vm.startPrank(msg.sender);
        vm.expectRevert(MigrationManager.MigrationManager__ZeroAddressRecipient.selector);
        mm.depositTo(100 ether, address(0));
        vm.stopPrank();
    }

    function test_deposit_to_succeeds() public {
        vm.startPrank(msg.sender);
        fwb.approve(address(mm), 100 ether);
        vm.expectEmit(true, true, true, true);
        emit Deposit(1, msg.sender, USER1, 100 ether, block.timestamp);
        mm.depositTo(100 ether, USER1);
        MigrationManager.DepositInfo memory depositInfo = mm.getDepositInfo(1);
        assertEq(depositInfo.amount, 100 ether);
        assertEq(depositInfo.recipient, USER1);
        assertEq(depositInfo.depositor, msg.sender);
        assertEq(depositInfo.depositId, 1);
        assertEq(depositInfo.timestamp, vm.getBlockTimestamp());
        assertEq(mm.getDepositCount(), 1);
        assertEq(fwb.balanceOf(address(mm)), 100 ether);
        vm.stopPrank();
    }

    function test_multiple_deposit_succeeds() public {
        vm.startPrank(msg.sender);
        fwb.mint(msg.sender, 1000 ether);
        fwb.approve(address(mm), 1000 ether);
        mm.deposit(100 ether);
        mm.deposit(200 ether);
        mm.deposit(300 ether);
        assertEq(mm.getDepositInfo(1).amount, 100 ether);
        assertEq(mm.getDepositInfo(2).amount, 200 ether);
        assertEq(mm.getDepositInfo(3).amount, 300 ether);
        assertEq(mm.getDepositCount(), 3);
        assertEq(fwb.balanceOf(address(mm)), 600 ether);
        vm.stopPrank();
    }

    function test_burn_reverts_with_OwnableUnauthorizedAccount() public {
        TestToken _fwb;
        MigrationManager _mm;
        // Initializations
        vm.startPrank(msg.sender);
        _fwb = new TestToken();
        _fwb.mint(USER1, 100 ether);
        _mm = new MigrationManager(address(_fwb));
        vm.stopPrank();
        // deposit amount
        vm.startPrank(USER1);
        _fwb.approve(address(_mm), 100 ether);
        _mm.deposit(100 ether);
        vm.stopPrank();
        // burn amount
        vm.startPrank(USER2);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, USER2));
        _mm.burn(100 ether);
        vm.stopPrank();
    }

    function test_burn_succeeds() public {
        TestToken _fwb;
        MigrationManager _mm;
        // Initializations
        vm.startPrank(USER1);
        _fwb = new TestToken();
        _fwb.mint(USER2, 100 ether);
        _mm = new MigrationManager(address(_fwb));
        vm.stopPrank();
        // deposit amount
        vm.startPrank(USER2);
        _fwb.approve(address(_mm), 100 ether);
        _mm.deposit(100 ether);
        vm.stopPrank();
        // burn amount
        vm.startPrank(USER1);
        _mm.burn(100 ether);
        assertEq(_fwb.balanceOf(address(_mm)), 0);
        vm.stopPrank();
    }
}
