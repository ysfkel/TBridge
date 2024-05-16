// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
 
import "./IFWBToken.sol";
import "@openzeppelin/access/Ownable.sol";

contract MigrationMinager is Ownable{

    event Deposit(address account, address recipient, uint256 amount);

    mapping(address => uint256) public deposits;
    mapping(address from => mapping(address to =>  uint256 amount)) public depositsTo;
    IFWBToken public migrationToken;

    constructor(address _migrationToken) Ownable(msg.sender) {
        require(_migrationToken != address(0), "0x0__migrationToken");
        migrationToken = IFWBToken(_migrationToken);
    }
     
    /**
     * 
     * @param amount amount to transfer 
     */
    function deposit(uint256 amount) external {
       _deposit(amount, msg.sender);
    }

    function depositTo(uint256 amount, address to) external {
       _deposit(amount, to);
    }

    function burn(uint256 amount) public onlyOwner() {
        migrationToken.burn(amount);
    } 

    function _deposit(uint256 amount, address to ) private {
       deposits[msg.sender] += amount;
       depositsTo[msg.sender][to] += amount;
       migrationToken.transferFrom(msg.sender, address(this), amount);
       emit Deposit(msg.sender, to, amount);
    }

}