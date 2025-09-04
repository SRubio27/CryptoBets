// License
// SPDX-License-Identifier: MIT

// Solidity version
pragma solidity 0.8.28;

// Imports
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract CryptoBets is Ownable{

    // Use 2 decimals scaling for odds
    // Example: 1.25 => 125, 2.10 => 210
    uint256 constant DECIMALS = 100;

    struct Bet {

        bytes32 name;
        string[2] teams;
        uint256[2] odds;
        bool open;
        
    }

    struct Wager {
        uint256 teamBet;
        uint256 amount;
    }

    uint256 public nextBetId;
    mapping(uint256 => Bet) public bets;
    mapping(uint256 => mapping(address => Wager)) public wagers; // betId → usuario → datos
    mapping(uint256 => address[]) public betPlayers;
    mapping(bytes32 => bool) public betExists;
    mapping(address => uint256) public balances;

    // Events
    event Deposit(address account_, uint256 amount_);

    // Modifiers
    modifier betIdExists(uint256 betId_) {
        if(betId_ >= nextBetId){
            revert("Bet does not exist");
        }
        _;
    }

    constructor(address owner_) Ownable(owner_) {
        nextBetId = 0;
    }

    // Bank functions

    function deposit() external payable {
        require(msg.value > 0, "Must send ETH");
        balances[msg.sender] += msg.value;

        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount_) external {
        require(amount_ <= balances[msg.sender], "Insufficient balance");

        balances[msg.sender] -= amount_;

        (bool success, ) = msg.sender.call{value: amount_}("");
        require(success, "Transfer failed");

    }

    // Wage functions

    function placeWager(uint256 betId_, uint256  teamBet_, uint256 amount_) external payable betIdExists(betId_){
        require(bets[betId_].open == true, "This bet is closed");
        require(amount_ > 0, "U must bet ETH");
        require(amount_ <= balances[msg.sender], "Insufficcient balance, deposit first");

        Wager memory wager_ = Wager(teamBet_, amount_);
        balances[msg.sender] -= amount_; 
        wagers[betId_][msg.sender] = wager_;
        betPlayers[betId_].push(msg.sender);

    }


    // Bets Functions

    function createBet(
        bytes32 betName_, 
        string memory team1,
        string memory team2,
        uint256 odd1,
        uint256 odd2 ) external onlyOwner {
        
        require(!betExists[betName_], "This bet name already exists");

        uint256 betId_ = nextBetId;

        Bet memory bet_ = Bet(betName_, [team1, team2], [odd1, odd2], true);

        betExists[betName_] = true;
        bets[betId_] = bet_;
        nextBetId++;
    }

    function resolveBet(uint256 betId_, uint256 winnerTeam_) external onlyOwner betIdExists(betId_) {
        require(bets[betId_].open == true, "Bet already solved or not operable");
        Bet storage bet_ = bets[betId_];
        // to do requires (bet exist, bet not finalized)
        pauseBet(betId_);
        

        for(uint256 i = 0; i < betPlayers[betId_].length; i++) {
            address player_ = betPlayers[betId_][i]; // position 0 of player list in this bet
            Wager memory wager_ = wagers[betId_][player_]; // wager of this player "i"

            if (winnerTeam_ == wager_.teamBet) {
                uint256 reward_ = wager_.amount * bet_.odds[winnerTeam_] / DECIMALS;
                balances[player_] += reward_;

            } else {
                wagers[betId_][player_].amount = 0;
            }
        
        }
        

    }
    

    function pauseBet(uint256 betId_) internal onlyOwner {
        bets[betId_].open = false;
    }


}