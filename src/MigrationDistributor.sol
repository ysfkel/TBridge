// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MigrationDistributor {
    error MigrationDistributor__OnlyOwner();
    error MigrationDistributor__DepositNotFound(uint256 depositId);
    error MigrationDistributor__TokensAlreadyDistributed(uint256 depositId);
    error MigrationDistributor__TransferFailed(address account, uint256 amount);
    error MigrationDistributor__DepositExists(uint256 depositId);
    error MigrationDistributor__OnlyMigrationRecorder();
    error MigrationDistributor__OnlyMigrationProcessor();

    event RecordDeposit(uint256 depositId, address recipient, uint256 amount);
    event DistributeTokens(uint256 depositId, address recipient, uint256 amount);

    uint256 _depositCount;
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

    mapping(uint256 => Deposit) public deposits;
    mapping(address => uint256[]) public userDepositIds;

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert MigrationDistributor__OnlyOwner();
        }
        _;
    }

    modifier onlyMigrationRecorder() {
        if (msg.sender != migrationRecorder) {
            revert MigrationDistributor__OnlyMigrationRecorder();
        }
        _;
    }

    modifier onlyMigrationProcessor() {
        if (msg.sender != migrationProcessor) {
            revert MigrationDistributor__OnlyMigrationProcessor();
        }
        _;
    }

    constructor(uint256 _conversionRate, address _baseToken, address _migrationRecorder, address _migrationProcessor) {
        baseToken = IERC20(_baseToken);
        owner = msg.sender;
        migrationRecorder = _migrationRecorder;
        migrationProcessor = _migrationProcessor;
        conversionRate = _conversionRate;
    }

    function recordDeposit(uint256 depositId, address recipient, uint256 amount)
        external
        onlyMigrationRecorder
        returns (uint256)
    {
        if (deposits[depositId].recipient != address(0)) {
            revert MigrationDistributor__DepositExists(depositId);
        }

        uint256 baseAmount = amount * conversionRate;
        deposits[depositId] = Deposit(recipient, baseAmount, false);
        userDepositIds[recipient].push(depositId);
        emit RecordDeposit(depositId, recipient, baseAmount);
        return depositId;
    }

    function distributeTokens(uint256 depositId) external onlyMigrationProcessor {
        Deposit memory deposit = deposits[depositId];
        if (deposit.recipient == address(0)) {
            revert MigrationDistributor__DepositNotFound(depositId);
        }

        if (deposit.processed) {
            revert MigrationDistributor__DepositNotFound(depositId);
        }

        if (baseToken.transfer(deposit.recipient, deposit.amount) == false) {
            revert MigrationDistributor__TransferFailed(deposit.recipient, deposit.amount);
        }

        deposits[depositId].processed = true;

        emit DistributeTokens(depositId, deposit.recipient, deposit.amount);
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

    function getDepositCount() public view returns (uint256) {
        return _depositCount;
    }
}
