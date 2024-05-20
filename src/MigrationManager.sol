// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
 
import "./IFWBToken.sol";
import "@openzeppelin/access/Ownable.sol";

contract MigrationManager is Ownable{

    event Deposit(address indexed account, address indexed recipient, uint256 amount);
    
    struct UserDeposit {
        address recipient;
        uint256 amount;
    }

    uint256 public totalDeposits;

    mapping(address => uint256) public deposits;
    mapping(address => address[]) public recipients;
    mapping(address from => mapping(address to =>  UserDeposit[])) public depositsTo;
    IFWBToken public migrationToken;

    constructor(address _migrationToken) Ownable(msg.sender) {
        require(_migrationToken != address(0), "0x0__migrationToken");
        migrationToken = IFWBToken(_migrationToken);
    }
     
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
       totalDeposits +=amount;
       deposits[msg.sender] += amount;

       depositsTo[msg.sender][to].push(UserDeposit({
          recipient: to,
          amount: amount
       }));

       if(depositsTo[msg.sender][to].length == 0) {
            recipients[msg.sender].push(to);
       }

       migrationToken.transferFrom(msg.sender, address(this), amount);
       emit Deposit(msg.sender, to, amount);
    }

}

//R / W ./ R / 
//R / R /  W 