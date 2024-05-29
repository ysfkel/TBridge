// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IFWBToken.sol";
import "@openzeppelin/access/Ownable.sol";

/**
 * @title MigrationManager
 * @notice This contract facilitates the exchange of $FWB on ETH mainnet
 *  for a corresponding amount of Base $FWB.
 */
contract MigrationManager is Ownable {
    error MigrationManager__ZeroAmount();
    error MigrationManager__ZeroAddressRecipient();
    error MigrationManager__ZeroAddressFwbToken();
    error MigrationManager__TransferFailed(address depositor, uint256 amount);

    event Deposit(uint64 indexed depositId, address indexed account, address indexed recipient, uint256 amount, uint256 timestamp);
    event Burn(address account, uint256 amount);

    struct DepositInfo {
        uint64 depositId;
        address depositor;
        address recipient;
        uint256 amount;
        uint256 timestamp;
    }

    uint64 private _depositCount;
    mapping(address => uint64[]) public depositIds;
    mapping(uint256 => DepositInfo) public deposits;
    IFWBToken public fwbToken;

    constructor(address _fwbToken) Ownable(msg.sender) {
        if (_fwbToken == address(0)) {
            revert MigrationManager__ZeroAddressFwbToken();
        }

        fwbToken = IFWBToken(_fwbToken);
    }

    /**
     * @notice Deposits tokens with the sender's address specified as the Base recipient.
     * @param amount The amount of tokens to deposit.
     */
    function deposit(uint256 amount) external {
        _deposit(amount, msg.sender);
    }

    /**
     * @notice Deposits tokens with another address specified as the Base recipient.
     * @param amount The amount of tokens to deposit.
     * @param recipient The address of the recipient.
     */
    function depositTo(uint256 amount, address recipient) external {
        if (recipient == address(0)) {
            revert MigrationManager__ZeroAddressRecipient();
        }
        _deposit(amount, recipient);
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
     * @return depositInfo The details of the deposit.
     */
    function getDepositInfo(uint64 depositId) external view returns (DepositInfo memory) {
        return deposits[depositId];
    }

    /**
     * @notice Returns the deposit count
     * @return count of deposits
     */
    function getDepositCount() public view returns (uint256) {
        return _depositCount;
    }

    function _deposit(uint256 amount, address recipient) private {
        if (amount == 0) {
            revert MigrationManager__ZeroAmount();
        }

        uint64 depositId = _getNextDepositId();

        uint256 timestamp = block.timestamp;

        deposits[depositId] =
            DepositInfo({depositId: depositId, depositor: msg.sender, recipient: recipient, amount: amount,
            timestamp: timestamp
            });

        depositIds[msg.sender].push(depositId);

        if (fwbToken.transferFrom(msg.sender, address(this), amount) == false) {
            revert MigrationManager__TransferFailed(msg.sender, amount);
        }
        emit Deposit(depositId, msg.sender, recipient, amount, timestamp);
    }

    function _getNextDepositId() private returns (uint64) {
        return ++_depositCount;
    }
}
