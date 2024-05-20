// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/token/ERC20/ERC20.sol";

contract TestToken is ERC20("test", "test") {
    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }

    function burn(uint256 value) external {
        _burn(msg.sender, value);
    }
}
