// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {Ownable} from "@openzeppelin/access/Ownable.sol";
import {Test, console} from "forge-std/Test.sol";
import {MigrationDistributor} from "../src/MigrationDistributor.sol";
import {MigrationManager} from "../src/MigrationManager.sol";
import {TestToken} from "./TestToken.sol";

contract MigrationDistributorTest is Test {
    event RecordDeposit(uint64 depositId, address recipient, uint256 amount);
    event DistributeTokens(uint64 depositId, address recipient, uint256 amount);
    event SetTransferDelay(uint256 transferDelay);

    uint256 transferDelay = 0; 
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
        md = new MigrationDistributor(conversionRate,transferDelay,  address(fwb), migrationRecorder, migrationProcessor);
        fwb.mint(address(md), 1000000 ether);
    }

    function test_constructor_reverts_with_MigrationDistributor__ZeroConversionRate() public {
        vm.expectRevert(MigrationDistributor.MigrationDistributor__ZeroConversionRate.selector);
        new MigrationDistributor(0, transferDelay, address(fwb), migrationRecorder, migrationProcessor);
    }

    function test_constructor_reverts_with_MigrationDistributor__ZeroAddress_BaseToken() public {
        vm.expectRevert(MigrationDistributor.MigrationDistributor__ZeroAddress_BaseToken.selector);
        new MigrationDistributor(conversionRate,transferDelay, address(0), migrationRecorder, migrationProcessor);
    }

    function test_constructor_reverts_with_MigrationDistributor__ZeroAddress_MigrationRecorder() public {
        vm.expectRevert(MigrationDistributor.MigrationDistributor__ZeroAddress_MigrationRecorder.selector);
        new MigrationDistributor(conversionRate,transferDelay, address(fwb), address(0), migrationProcessor);
    }

    function test_constructor_reverts_with_MigrationDistributor__ZeroAddress_MigrationProcessor() public {
        vm.expectRevert(MigrationDistributor.MigrationDistributor__ZeroAddress_MigrationProcessor.selector);
        new MigrationDistributor(conversionRate,transferDelay, address(fwb), migrationRecorder, address(0));
    }

    function test_constructor_succeeds() public view {
        assertEq(address(md.baseToken()), address(fwb));
        assertEq(address(md.migrationRecorder()), migrationRecorder);
        assertEq(address(md.migrationProcessor()), migrationProcessor);
        assertEq(md.conversionRate(), conversionRate);
        assertEq(md.transferDelay(), transferDelay);
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
        assertEq(deposit.baseAmount, 0);
        uint256 index = md.getDepositStatusIndex(1);
        assertEq(md.getDepositStatuses()[index].isProcessed, false);
        vm.stopPrank();
    }

    function test_recordDeposit_succeeds_should_add_depositStatuses() public {
        vm.startPrank(migrationRecorder);
        uint256 amount = 100 ether; 
        md.recordDeposit(1, USER1, amount); 
        md.recordDeposit(2, USER1, amount); 
        md.recordDeposit(3, USER1, amount);  
        assertEq(md.getDepositStatuses()[md.getDepositStatusIndex(1)].depositId, 1);
        assertEq(md.getDepositStatuses()[md.getDepositStatusIndex(2)].depositId, 2);
        assertEq(md.getDepositStatuses()[md.getDepositStatusIndex(3)].depositId, 3);
        vm.stopPrank();
    }

    function test_recordDeposit_succeeds_should_increment_depositStatusIndexes() public {
        vm.startPrank(migrationRecorder);
        uint256 amount = 100 ether; 
        md.recordDeposit(1, USER1, amount); 
        md.recordDeposit(2, USER1, amount); 
        md.recordDeposit(3, USER1, amount);  
        assertEq(md.getDepositStatusIndex(1), 0);
        assertEq(md.getDepositStatusIndex(2), 1);
        assertEq(md.getDepositStatusIndex(3), 2);
        vm.stopPrank();
    }

    function test_distributeTokens_reverts_with_MigrationDistributor__TransferDelayNotElapsed() public {
        
        vm.startPrank(msg.sender); 
        uint256 _transferDelay = 3*3600; 
        MigrationDistributor _md = new MigrationDistributor(conversionRate,_transferDelay,  address(new TestToken()), migrationRecorder, migrationProcessor);
        vm.stopPrank();

        vm.startPrank(migrationProcessor);
        uint64 depositId = 1;
        vm.expectRevert(abi.encodeWithSelector(MigrationDistributor.MigrationDistributor__TransferDelayNotElapsed.selector, depositId));
        _md.distributeTokens(depositId);
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
        uint64 depositId = 2;
        vm.expectRevert(
            abi.encodeWithSelector(MigrationDistributor.MigrationDistributor__DepositNotFound.selector, depositId)
        );
        md.distributeTokens(depositId);
        vm.stopPrank();
    }

    function test_distributeTokens_reverts_with_MigrationDistributor__TokensAlreadyDistributed() public {
        uint64 depositId = 2;
        vm.startPrank(migrationRecorder);
        md.recordDeposit(depositId, USER1, 100 ether);
        vm.stopPrank();

        vm.startPrank(migrationProcessor);
        md.distributeTokens(depositId);
        vm.expectRevert(
            abi.encodeWithSelector(
                MigrationDistributor.MigrationDistributor__TokensAlreadyDistributed.selector, depositId
            )
        );
        md.distributeTokens(depositId);
        vm.stopPrank();
    }

    function test_distributeTokens_succeeds() public {
        uint64 depositId = 2;
        uint256 amount = 7900 ether;
        vm.startPrank(migrationRecorder);
        md.recordDeposit(depositId, USER3, amount);
        vm.stopPrank();
        vm.startPrank(migrationProcessor);
        vm.expectEmit(true, true, true, true);
        emit DistributeTokens(depositId, USER3, amount * conversionRate);
        assertEq(md.isProcessed(depositId), false);
        md.distributeTokens(depositId);
        assertEq(md.isProcessed(depositId), true);
        assertEq(md.getDeposit(depositId).baseAmount, amount * conversionRate);
        assertEq(fwb.balanceOf(USER3), amount * conversionRate);
        vm.stopPrank();
    }

    function test_distributeTokens_succeeds_should_update_depositStatus_isProcessed_true() public {
        uint64 depositId = 2;
        uint256 amount = 7900 ether;
        vm.startPrank(migrationRecorder);
        md.recordDeposit(depositId, USER3, amount);
        vm.stopPrank();
        vm.startPrank(migrationProcessor);
 
        md.distributeTokens(depositId); 
        assertEq(md.getDepositStatuses()[md.getDepositStatusIndex(depositId)].isProcessed, true);
        vm.stopPrank();
    }

    function test_setTransferDelay_reverts_with_OwnableUnauthorizedAccount() public {

        vm.startPrank(msg.sender); 
        MigrationDistributor _md = new MigrationDistributor(conversionRate, 0,  address(new TestToken()), migrationRecorder, migrationProcessor);
        vm.stopPrank();

        vm.startPrank(USER1); 
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, USER1));
        _md.setTransferDelay(3 * 3600);
        vm.stopPrank();
    }

    function test_setTransferDelay_succeeds() public {
        vm.startPrank(msg.sender); 
        MigrationDistributor _md = new MigrationDistributor(conversionRate, 0,  address(new TestToken()), migrationRecorder, migrationProcessor);
        uint256 _transferDelay = 3 * 3600;
        vm.expectEmit(true, true, true, true);
        emit SetTransferDelay( _transferDelay);
        _md.setTransferDelay(3 * 3600);
        vm.stopPrank();
    }
}
