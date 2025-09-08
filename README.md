# 🂮 CryptoBets
A **decentralized betting smart contract** on Ethereum, built with Solidity and tested with Foundry. Users can **deposit ETH, create bets, participate in wagers, and withdraw winnings**, all managed sec---
## ✨ Features
- 🪙 **Deposit & Withdraw ETH** with per-user balance tracking.
- 📄 **Bet Creation** restricted to the contract owner (`Ownable`).
- 🎲 **Place wagers** on open bets by choosing a team and an amount.
- 🏆 **Resolve bets** with automated reward distribution based on odds.
- 🔒 Built-in safety checks with reverts for:
 - Insufficient balance.
 - Failed ETH transfers.
 - Betting on non-existent or closed bets.
 - Duplicate bet names.
---
## 📂 Project Structure
.
├── src/
│   ├── CryptoBets.sol            # Main contract
│
├── test/
│   ├── StakingTokenTest.t.sol    # Main Foundry test suite
│   ├── RejectETH.t.sol           # Helper contract to simulate failed transfers
│   ├── CryptoBetsTestable.t.sol  # Additional tests on getters
│
├── lib/
│   └── openzeppelin-contracts    # OpenZeppelin dependency
---
## ⚙️ Installation
forge install
---
## 🔨 Compile contracts
forge build
---
## 🧪 Run tests
forge test -vvvv
---
## 📊 Test Coverage
The test suite (`StakingTokenTest.t.sol`) includes:
- **Deposit**
 - Reverts if no ETH is sent.
 - Updates balances correctly.
- **Withdraw**
 - Reverts on insufficient balance.
 - Reverts if ETH transfer fails (via `RejectETH`).
 - Withdraws successfully and updates balances.
- **Bet Creation**
 - Restricted to owner only.
 - Reverts if bet name already exists.
 - Creates bets with correct data.
- **Place Wager**
 - Reverts if betting on a non-existent bet.
 - Reverts if bet already resolved.
 - Reverts if insufficient funds.
 - Places wager successfully and updates storage.
- **Resolve Bet**
 - Restricted to owner only.
 - Reverts if bet does not exist.
 - Reverts if bet already resolved.
 - Distributes winnings correctly to winners.
