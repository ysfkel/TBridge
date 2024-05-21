// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {MigrationDistributor} from "../src/MigrationDistributor.sol";
import {MigrationManager} from "../src/MigrationManager.sol";
import {TestToken} from "./TestToken.sol";

contract MigrationDistributorTest is Test {
    event RecordDeposit(uint256 depositId, address recipient, uint256 amount);
    event DistributeTokens(uint256 depositId, address recipient, uint256 amount);

    uint256 conversionRate = 10;
    MigrationDistributor md;
    TestToken fwb;
    address USER1 = makeAddr("USER1");
    address USER2 = makeAddr("USER2"); 
    address USER3 = makeAddr("USER3");
    address migrationRecorder = makeAddr("migrationRecorder");
    address migrationProcessor = makeAddr("migrationProcessor");

    function setUp() public {
        fwb = new TestToken();
        fwb.mint(msg.sender, 5000000 ether);
        fwb.mint(USER1, 1000 ether);
        fwb.mint(USER2, 1000 ether);
        md = new MigrationDistributor(conversionRate, address(fwb), migrationRecorder, migrationProcessor);
        fwb.mint(address(md), 1000000 ether);
    }

    function test_constructor() public view {
        assertEq(address(md.baseToken()), address(fwb));
        assertEq(address(md.migrationRecorder()), migrationRecorder);
        assertEq(address(md.migrationProcessor()), migrationProcessor);
        assertEq(md.conversionRate(), conversionRate);
    }

    function test_recordDeposit_reverts_with_MigrationDistributor__OnlyMigrationRecorder() public {
        vm.startPrank(msg.sender);
        vm.expectRevert(MigrationDistributor.MigrationDistributor__OnlyMigrationRecorder.selector);
        md.recordDeposit(1, USER2, 100 ether);
        vm.stopPrank();
    }

    function test_recordDeposit_succeeds() public {
        vm.startPrank(migrationRecorder);
        uint256 amount = 100 ether;
        vm.expectEmit(true, true, true, true);
        emit RecordDeposit(1, USER1, amount);
        md.recordDeposit(1, USER1, amount);
        MigrationDistributor.Deposit memory deposit = md.getDeposit(1);
        assertEq(deposit.amount, amount);
        vm.stopPrank();
    }

    function test_distributeTokens_reverts_with_MigrationDistributor__OnlyMigrationProcessor() public {
        vm.startPrank(migrationRecorder);
        vm.expectRevert(MigrationDistributor.MigrationDistributor__OnlyMigrationProcessor.selector);
        md.distributeTokens(1);
        vm.stopPrank();
    }

    function test_distributeTokens_reverts_with_MigrationDistributor__DepositNotFound() public {
        vm.startPrank(migrationProcessor);
        uint256 depositId = 2;
        vm.expectRevert(abi.encodeWithSelector(MigrationDistributor.MigrationDistributor__DepositNotFound.selector, depositId));
        md.distributeTokens(depositId);
        vm.stopPrank();
    }

    function test_distributeTokens_reverts_with_MigrationDistributor__TokensAlreadyDistributed() public {
        uint256 depositId = 2;
        vm.startPrank(migrationRecorder);
        md.recordDeposit(depositId, USER1, 100 ether);
        vm.stopPrank();

        vm.startPrank(migrationProcessor);
        md.distributeTokens(depositId);
        vm.expectRevert(abi.encodeWithSelector(MigrationDistributor.MigrationDistributor__TokensAlreadyDistributed.selector, depositId));
        md.distributeTokens(depositId);
        vm.stopPrank();
    }

    function test_distributeTokens_succeeds() public {
        uint256 depositId = 2;
        uint256 amount = 7900 ether;
        vm.startPrank(migrationRecorder);
        md.recordDeposit(depositId, USER3, amount);
        vm.stopPrank();
        vm.startPrank(migrationProcessor);
        vm.expectEmit(true, true, true, true);
        emit DistributeTokens(depositId, USER3, amount * conversionRate);
        assertEq(md.getDeposit(depositId).processed, false);
        md.distributeTokens(depositId);
        assertEq(md.getDeposit(depositId).processed, true);
        assertEq(fwb.balanceOf(USER3), amount * conversionRate);
        vm.stopPrank();
    }
}
