// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import {Test, console} from "forge-std/Test.sol";
// import { MigrationDistributor } from "../src/MigrationDistributor.sol";
// import { TestToken } from "./TestToken.sol";

// contract MigrationDistributorTest is Test {
//     event RecordDeposit(uint256 depositId, address recipient, uint256 amount);
//     event DistributeTokens(uint256 depositId, address recipient, uint256 amount);

//     uint256 conversionRate = 10;
//     MigrationDistributor md;
//     TestToken fwb;
//     address USER1 =  makeAddr("USER1");
//     address USER2 =  makeAddr("USER2");
//     address migrationRecorder =  makeAddr("migrationRecorder");
//     address migrationProcessor =  makeAddr("migrationProcessor");

//     function setUp() public {
//         fwb = new TestToken();
//         fwb.mint(msg.sender, 1000 ether);
//         fwb.mint(USER1, 1000 ether);
//         fwb.mint(USER2, 1000 ether);
//         md = new MigrationDistributor(conversionRate, address(fwb),migrationRecorder, migrationProcessor);
//     }

//     function test_constructor() view public  {
//         assertEq(address(md.baseToken()), address(fwb));
//         assertEq(address(md.migrationRecorder()), migrationRecorder);
//         assertEq(address(md.migrationProcessor()), migrationProcessor);
//         assertEq(md.conversionRate(), conversionRate);
//     }

//     function test_recordDeposit_reverts_with_MigrationDistributor__OnlyMigrationRecorder()  public  {
//         vm.startPrank(msg.sender);
//         vm.expectRevert(MigrationDistributor.MigrationDistributor__OnlyMigrationRecorder.selector);
//         md.recordDeposit(USER1, 100 ether);
//         vm.stopPrank();
//     }

//     function test_recordDeposit_succeeds()  public  {
//         vm.startPrank(migrationRecorder);
//         uint256 amount = 100 ether;
//         vm.expectEmit(true, true, true, true);
//         emit RecordDeposit(1, USER1, amount);
//         md.recordDeposit(USER1, amount);
//         assertEq(md.getDepositCount(), 1);
//         MigrationDistributor.Deposit memory deposit = md.getDeposit(0);
//         assertEq(deposit.amount, amount * conversionRate);
//         vm.stopPrank();
//     }
// }
