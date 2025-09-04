// License
// SPDX-License-Identifier: MIT

// Solidity version
pragma solidity 0.8.28;

contract RejectETH {
    receive() external payable {
        revert("I do not accept ETH");
    }
}