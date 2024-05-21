// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title MigrationDistributor 
 * @notice This  contract transfers Base mainnet $FWB tokens to mainnet $FWB holders who have locked 
 * their tokens in the migration manager on ETH mainnet
 */
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

    IERC20 public baseToken;
    address public owner;
    address public migrationRecorder;
    address public migrationProcessor;
    uint256 public conversionRate;

    struct Deposit {
        address recipient;
        uint256 amount;
        uint256 baseAmount;
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

    /**
     * @notice Adds details of deposit which has been received at the migration manager on mainnet 
     * @param depositId Id of the deposit 
     * @param recipient Addrses which will receive the fwb token on base 
     * @param amount which was deposited on the migration manager
     * @dev The depositId is generated at the migration manager
     */
    function recordDeposit(uint256 depositId, address recipient, uint256 amount)
        external
        onlyMigrationRecorder
        returns (uint256)
    {
        if (deposits[depositId].recipient != address(0)) {
            revert MigrationDistributor__DepositExists(depositId);
        }

        deposits[depositId] = Deposit({
           recipient: recipient, amount: amount,processed: false,
           baseAmount:0
        });
        userDepositIds[recipient].push(depositId);
        emit RecordDeposit(depositId, recipient, amount);
        return depositId;
    }

    /**
     * @notice Processes the deposit by distributing FWB tokens to the receiving address
     * @param depositId Id of the deposit  
     */
    function distributeTokens(uint256 depositId) external onlyMigrationProcessor {
        Deposit memory deposit = deposits[depositId];
        if (deposit.recipient == address(0)) {
            revert MigrationDistributor__DepositNotFound(depositId);
        }

        if (deposit.processed) {
            revert MigrationDistributor__TokensAlreadyDistributed(depositId);
        }
        
        uint256 baseAmount =  _getBaseAmount(deposit.amount);

        if (baseToken.transfer(deposit.recipient, baseAmount) == false) {
            revert MigrationDistributor__TransferFailed(deposit.recipient, baseAmount);
        }

        deposits[depositId].processed = true;
        deposits[depositId].baseAmount = baseAmount;

        emit DistributeTokens(depositId, deposit.recipient, baseAmount);
    }

    /**
     * @notice Fetches Deposit details
     * @param depositId Id of the deposit  
     */
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

    function getBaseAmount(uint256 amount) external view returns(uint256) {
        return _getBaseAmount(amount);
    }

    function _getBaseAmount(uint256 amount) private view returns(uint256) {
        return amount * conversionRate;
    }
}
