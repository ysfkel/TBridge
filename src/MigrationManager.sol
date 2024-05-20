pragma solidity ^0.8.13;

import "./IFWBToken.sol";
import "@openzeppelin/access/Ownable.sol";

contract MigrationManager is Ownable {
    IFWBToken public fwbToken;
    uint256 public depositCount;

    struct DepositInfo {
        address depositor;
        address recipient;
        uint256 amount;
    }

    DepositInfo[] public deposits;

    event Deposit(address indexed depositor, address indexed recipient, uint256 amount, uint256 depositId);

    constructor(address _fwbToken) Ownable(msg.sender) {
        require(_fwbToken != address(0), "MigrationManager: invalid token address");
        fwbToken = IFWBToken(_fwbToken);
    }

    /**
     * @notice Deposits tokens to the sender's own account.
     * @param amount The amount of tokens to deposit.
     */
    function deposit(uint256 amount) external {
        _deposit(msg.sender, amount, msg.sender);
    }

    /**
     * @notice Deposits tokens to another specified account.
     * @param recipient The address of the recipient.
     * @param amount The amount of tokens to deposit.
     */
    function depositTo(address recipient, uint256 amount) public {
        _deposit(msg.sender, amount, recipient);
    }

    /**
     * @notice Retrieves the details of a specific deposit by ID.
     * @param depositId The ID of the deposit.
     * @return depositor The address of the depositor.
     * @return recipient The address of the recipient.
     * @return amount The amount of tokens deposited.
     */
    function getDeposit(uint256 depositId) external view returns (address depositor, address recipient, uint256 amount) {
        require(depositId < depositCount, "MigrationManager: invalid deposit ID");
        DepositInfo storage deposit = deposits[depositId];
        return (deposit.depositor, deposit.recipient, deposit.amount);
    }

    /**
     * @notice Burns a specified amount of tokens. Only the contract owner can call this function.
     * @param amount The amount of tokens to burn.
     */
    function burn(uint256 amount) external onlyOwner {
        fwbToken.burn(amount);
    }

    function _deposit(address from, uint256 amount, address recipient) internal {
        require(recipient != address(0), "MigrationManager: invalid recipient address");
        require(amount > 0, "MigrationManager: amount must be greater than 0");
        require(fwbToken.transferFrom(from, address(this), amount), "MigrationManager: transfer failed");

        deposits.push(DepositInfo(from, recipient, amount));
        emit Deposit(from, recipient, amount, depositCount);
        depositCount++;
    }
}