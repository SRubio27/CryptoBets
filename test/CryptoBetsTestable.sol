// License
// SPDX-License-Identifier: MIT

// Solidity version
pragma solidity 0.8.28;

// Imports
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../src/CryptoBets.sol";

contract CryptoBetsTestable is CryptoBets{
    
    constructor(address owner_) CryptoBets(owner_) {}

    function getTeams(uint256 betId_) external view returns (string memory, string memory) {
        return (bets[betId_].teams[0], bets[betId_].teams[1]);
    }

    function getOdds(uint256 betId_) external view returns (uint256, uint256) {
        return (bets[betId_].odds[0], bets[betId_].odds[1]);
    }
}