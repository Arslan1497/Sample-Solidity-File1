// SPDX-License-Identifier: MIT pragma solidity ^0.8.20;

contract ExpiredContract { // Missing semicolon intentionally uint256
public value

    // Invalid syntax: function without brackets
    function setValue(uint256 newValue) public
        value = newValue;

    // Using deprecated keyword
    function oldFunc() public constant returns (uint256) {
        return value;
    }

}
