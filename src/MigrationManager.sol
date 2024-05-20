// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./IFWBToken.sol";
import "@openzeppelin/access/Ownable.sol";

contract MigrationManager is Ownable {
    error MigrationManager__ZeroAmount();
    error MigrationManager__ZeroAddressRecipient();
    error MigrationManager__ZeroAddressFwbToken();
    error MigrationManager__TransferFailed(address depositor, uint256 amount);

    event Deposit(address indexed account, address indexed recipient, uint256 amount);
    event Burn(address account, uint256 amount);

    struct DepositInfo {
        uint256 depositId;
        address depositor;
        address recipient;
        uint256 amount;
    }

    uint256 private _depositCount;
    mapping(address => uint256[]) public depositIds;
    mapping(uint256 => DepositInfo) public deposits;
    IFWBToken public fwbToken;

    constructor(address _fwbToken) Ownable(msg.sender) {
        if (_fwbToken == address(0)) {
            revert MigrationManager__ZeroAddressFwbToken();
        }

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
     * @param amount The amount of tokens to deposit.
     * @param recipient The address of the recipient.
     */
    function depositTo(uint256 amount, address recipient) external {
        if (recipient == address(0)) {
            revert MigrationManager__ZeroAddressRecipient();
        }
        _deposit(msg.sender, amount, recipient);
    }

    /**
     * @notice Burns a specified amount of tokens. Only the contract owner can call this function.
     * @param amount The amount of tokens to burn.
     */
    function burn(uint256 amount) public onlyOwner {
        fwbToken.burn(amount);
        emit Burn(msg.sender, amount);
    }

    /**
     * @notice Retrieves the details of a specific deposit by ID.
     * @param depositId The ID of the deposit.
     * @return depositInfo The address of the depositor.
     */
    function getDepositInfo(uint256 depositId) external view returns (DepositInfo memory) {
        return deposits[depositId];
    }

    /**
     * @notice Returns the deposit count
     * @return count of deposits
     */
    function getDepositCount() public view returns (uint256) {
        return _depositCount;
    }

    function _deposit(address from, uint256 amount, address recipient) private {
        if (amount == 0) {
            revert MigrationManager__ZeroAmount();
        }

        uint256 depositId = _getNextDepositId();

        deposits[depositId] = DepositInfo({depositId: depositId, depositor: from, recipient: recipient, amount: amount});

        depositIds[msg.sender].push(depositId);

        if (fwbToken.transferFrom(msg.sender, address(this), amount) == false) {
            revert MigrationManager__TransferFailed(msg.sender, amount);
        }
        emit Deposit(from, recipient, amount);
    }

    function _getNextDepositId() private returns (uint256) {
        return ++_depositCount;
    }
}
