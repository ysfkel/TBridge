// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MigrationDistributor {
    uint256  _depositCount;
    IERC20 public baseToken;
    address public owner;
    address public migrationRecorder;
    address public migrationProcessor;
    uint256 public conversionRate;

    struct Deposit {
        address recipient;
        uint256 amount;
        bool processed;
    }

    mapping(uint256  => Deposit) public deposits;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier onlyMigrationRecorder() {
        require(msg.sender == migrationRecorder, "Only migration recorder can call this function");
        _;
    }

    modifier onlyMigrationProcessor() {
        require(msg.sender == migrationProcessor, "Only migration processor can call this function");
        _;
    }

    event DepositRecorded(uint256 depositId, address recipient, uint256 amount);
    event TokensDistributed(uint256 depositId, address recipient, uint256 amount);

    constructor(uint256 _conversionRate, address _baseToken, address _migrationRecorder, address _migrationProcessor) {
        baseToken = IERC20(_baseToken);
        owner = msg.sender;
        migrationRecorder = _migrationRecorder;
        migrationProcessor = _migrationProcessor;
        conversionRate = _conversionRate;
    }

    function recordDeposit(address recipient, uint256 amount) external onlyMigrationRecorder returns (uint256) {
        uint256 depositId = _getNextDepositId();
        uint256 baseAmount = amount * conversionRate;
        deposits[depositId] = Deposit(recipient, baseAmount, false);
        emit DepositRecorded(depositId, recipient, baseAmount);
        return depositId;
    }

    function distributeTokens(uint256 depositId) external onlyMigrationProcessor {
        Deposit memory deposit = deposits[depositId];
        require(deposit.recipient != address(0), "0x0__deposit_does_not_exist");
        require(!deposit.processed, "Tokens already distributed");

        require(baseToken.transfer(deposit.recipient, deposit.amount), "Token transfer failed");
        deposits[depositId].processed = true;

        emit TokensDistributed(depositId, deposit.recipient, deposit.amount);
    }

    function getDeposit(uint256 depositId) external view returns (Deposit memory) {
        Deposit memory deposit = deposits[depositId];
        return deposit;
    }

    function changeMigrationRecorder(address newMigrationRecorder) external onlyOwner {
        migrationRecorder = newMigrationRecorder;
    }

    function changeMigrationProcessor(address newMigrationProcessor) external onlyOwner {
        migrationProcessor = newMigrationProcessor;
    }

    function _getNextDepositId()  private returns (uint256) {
        return _depositCount++;
    }

    function getDepositCount() public view returns (uint256) { 
        return _depositCount;
    }
}