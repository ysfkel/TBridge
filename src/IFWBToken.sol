// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";

interface IFWBToken is IERC20 {

    function burn(uint256 value) external;
    
}