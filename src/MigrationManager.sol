// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
 
import "./IFWBToken.sol";
import "@openzeppelin/access/AccessControl.sol";

contract MigrationMinager is AccessControl{

    event Deposit(address account, address recipient, uint256 amount);

    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    address public owner;
    mapping(address => uint256) public deposits;
    mapping(address from => mapping(address to =>  uint256 amount)) public depositsTo;
    IFWBToken public migrationToken;

    constructor(address _migrationToken,  address burner) {
        require(_migrationToken != address(0), "0x0 token");
        require(burner != address(0), "0x0 token");
       
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(BURNER_ROLE, burner);
        migrationToken = IFWBToken(_migrationToken);
    }
     
    /**
     * 
     * @param amount amount to transfer 
     */
    function deposit(uint256 amount, address ) external {
       _deposit(amount, msg.sender);
    }

    function depositTo(uint256 amount, address to) external {
       _deposit(amount, to);
    }

    function burn(uint256 amount) public onlyRole(BURNER_ROLE) {
        migrationToken.burn(amount);
    } 

    function _deposit(uint256 amount, address to ) private {
       deposits[msg.sender] += amount;
       depositsTo[msg.sender][msg.sender] += amount;
       migrationToken.transferFrom(msg.sender, address(this), amount);
       emit Deposit(msg.sender, to, amount);
    }

}