// License
// SPDX-License-Identifier: MIT

// Solidity version
pragma solidity 0.8.28;

import "../src/CryptoBets.sol";
import "./CryptoBetsTestable.sol";
import "./RejectETH.t.sol";

import "lib/forge-std/src/Test.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract StakingTokenTest is Test {
    CryptoBetsTestable cryptoBetsTestable;
    CryptoBets cryptoBets;
    RejectETH ethRejecter;

    address owner = vm.addr(1);
    address randomUser = vm.addr(2);
    address secondRandomUser = vm.addr(3);

    function setUp() public {
        cryptoBets = new CryptoBets(owner);
        cryptoBetsTestable = new CryptoBetsTestable(owner);
        ethRejecter = new RejectETH();
    }

    // tests deposit function 

    function testDepositRevertByMustSendETH() public {
        vm.startPrank(randomUser);
        
        uint256 balanaceBeforeDeposit = cryptoBets.balances(randomUser);
        vm.expectRevert("Must send ETH");
        cryptoBets.deposit{value: 0 ether}();
        uint256 balanaceAfterDeposit = cryptoBets.balances(randomUser);

        assert(balanaceAfterDeposit - balanaceBeforeDeposit == 0 ether);

        vm.stopPrank();
    }

    function testDepositCorrectly() public {
        vm.startPrank(randomUser);
        vm.deal(randomUser, 1 ether);
        
        uint256 balanaceBeforeDeposit = cryptoBets.balances(randomUser);
        cryptoBets.deposit{value: 1 ether}();
        uint256 balanaceAfterDeposit = cryptoBets.balances(randomUser);

        assert(balanaceAfterDeposit - balanaceBeforeDeposit == 1 ether);

        vm.stopPrank();
    }

    // tests withdraw function

    function testWithdrawRevesrtByInsufficientBalance() public {
        vm.startPrank(randomUser);

        // deposit ether
        vm.deal(randomUser, 1 ether);
    
        uint256 balanaceBeforeDeposit = cryptoBets.balances(randomUser);
        cryptoBets.deposit{value: 1 ether}();
        uint256 balanaceAfterDeposit = cryptoBets.balances(randomUser);
        
        assert(balanaceAfterDeposit - balanaceBeforeDeposit == 1 ether);

        // withdraw function
        vm.expectRevert("Insufficient balance");
        cryptoBets.withdraw(1.5 ether);

        vm.stopPrank();
    }

    function testTransferFailedWhenWithdraw() public {
        vm.startPrank(address(ethRejecter));
        vm.deal(address(ethRejecter), 1 ether);
        cryptoBets.deposit{value: 1 ether}();
        
        vm.expectRevert("Transfer failed");
        cryptoBets.withdraw(0.5 ether);

    }

    function testWithdrawCorrectly() public {
        vm.startPrank(randomUser);

        // deposit ether
        vm.deal(randomUser, 1 ether);
        uint256 balanceBeforeDeposit = cryptoBets.balances(randomUser);

        cryptoBets.deposit{value: 1 ether}();

        uint256 balanceAfterDeposit = cryptoBets.balances(randomUser);
        assert(balanceAfterDeposit - balanceBeforeDeposit == 1 ether);

        // withdraw
        uint256 contractBalanceBefore = cryptoBets.balances(randomUser);
        uint256 personalBalanceBefore = address(randomUser).balance;

        cryptoBets.withdraw(0.5 ether);

        uint256 contractBalanceAfter = cryptoBets.balances(randomUser);
        uint256 personalBalanceAfter = address(randomUser).balance;

        assert(contractBalanceBefore - contractBalanceAfter == 0.5 ether);
        assert(personalBalanceAfter - personalBalanceBefore == 0.5 ether);


        vm.stopPrank();
    }


    // tests function placeWager

    function testCanNotPlaceWagerCauseBetDontExist() public {
        vm.startPrank(randomUser);
        uint256 betId_ = 0;
        vm.deal(randomUser, 1 ether);
        cryptoBets.deposit{value: 1 ether}();
        uint256 amountToBet_ = 1 ether;

        vm.expectRevert("Bet does not exist");
        cryptoBets.placeWager(betId_, 0, amountToBet_);

        vm.stopPrank();
    }

    function testPlaceWagerRevertByNotOpen() public {
        vm.startPrank(owner);
        cryptoBets.createBet(bytes32("RMvsFCB"), "RM", "FCB", 120, 101);
        uint256 betId_ = 0;
        cryptoBets.resolveBet(betId_, 0);
        vm.stopPrank();

        vm.startPrank(randomUser);
        vm.deal(randomUser, 1 ether);
        cryptoBets.deposit{value: 1 ether}();
        uint256 amountToBet_ = 1 ether;

        vm.expectRevert("This bet is closed");
        cryptoBets.placeWager(betId_, 0, amountToBet_);

        vm.stopPrank();
        
    }

    function testRevertPlaceWagerFailedByInsufficientAmount() public {
        vm.startPrank(owner);
        cryptoBets.createBet(bytes32("RMvsFCB"), "RM", "FCB", 140, 160);
        vm.stopPrank();

        vm.startPrank(randomUser);
        vm.deal(randomUser, 1 ether);
        cryptoBets.deposit{value: 1 ether}();
        uint256 betId_ = 0;
        uint256  teamBet_ = 0;
        uint256 amountToBet_ = 0 ether;
        vm.expectRevert("U must bet ETH");
        cryptoBets.placeWager(betId_, teamBet_, amountToBet_);


        vm.stopPrank();

    }

    function testPlaceWagerCorrectly() public {
        // Create bet
        vm.startPrank(owner);
        cryptoBets.createBet(bytes32("RMvsFCB"), "RM", "FCB", 120, 101);
        vm.stopPrank();

        vm.startPrank(randomUser);
        vm.deal(randomUser, 1 ether);
        cryptoBets.deposit{value: 1 ether}();

        uint256 amountToBet_ = 0.5 ether;
        uint256 betId_ = 0;
        uint256  teamBet_ = 0;
        

        cryptoBets.placeWager(betId_, teamBet_, amountToBet_);
        
       (uint256 teamBet, uint256 amount) = cryptoBets.wagers(betId_, randomUser);

        assertEq(amount, 0.5 ether);
        assertEq(teamBet, 0);


        vm.stopPrank();
        //to do
    }


    // tests function createBet

    function testCreateBetCorrectly() public {
        vm.startPrank(owner);
        uint256 betId_ = cryptoBetsTestable.nextBetId();
        cryptoBetsTestable.createBet(bytes32("RMvsFCB"), "RM", "FCB", 120, 101);


        (bytes32 betName_,  bool open) = cryptoBetsTestable.bets(betId_);
        (string memory team1, string memory team2) = cryptoBetsTestable.getTeams(betId_);
        (uint256 odd1, uint256 odd2) = cryptoBetsTestable.getOdds(betId_);


        assertEq(betName_, bytes32("RMvsFCB"));
        assertEq(team1, "RM");
        assertEq(team2, "FCB");
        assertEq(odd1, 120);
        assertEq(odd2, 101);
        assertTrue(open);


        vm.stopPrank();
    }

    function testCreateBetRevertByBetNameAlreadyExists() public {
        vm.startPrank(owner);
        cryptoBetsTestable.createBet(bytes32("RMvsFCB"), "RM", "FCB", 120, 101);

        vm.expectRevert("This bet name already exists");
        cryptoBetsTestable.createBet(bytes32("RMvsFCB"), "RM", "FCB", 120, 101);


        vm.stopPrank();
    }
    

    // tests function resolveBet

    function testBetAlreadySolved() public {
        vm.startPrank(owner);
        cryptoBets.createBet(bytes32("RMvsFCB"), "RM", "FCB", 120, 101);
        cryptoBets.resolveBet(0, 0);

        vm.expectRevert("Bet already solved or not operable");
        cryptoBets.resolveBet(0, 0);



        vm.stopPrank();
    }

    function testResolveBetCorrectly() public {

        // Create Bet
        vm.startPrank(owner);
        cryptoBets.createBet(bytes32("RMvsFCB"), "RM", "FCB", 200, 101);
        vm.stopPrank();

        // First wage placement
        vm.startPrank(randomUser);
        vm.deal(randomUser, 1 ether);
        cryptoBets.deposit{value: 1 ether}();
        uint256 amountToBet_ = 1 ether;
        uint256 betId_ = 0;
        uint256 teamBet_ = 0;
        cryptoBets.placeWager(betId_, teamBet_, amountToBet_);
        vm.stopPrank();


        // Second wage placement
        vm.startPrank(secondRandomUser);
        vm.deal(secondRandomUser, 1 ether);
        cryptoBets.deposit{value: 1 ether}();
        amountToBet_ = 1 ether;
        betId_ = 0;
        teamBet_ = 1;
        cryptoBets.placeWager(betId_, teamBet_, amountToBet_);
        vm.stopPrank();


        // Solve bet
        vm.startPrank(owner);
        uint256 balanceLoserBefore = cryptoBets.balances(secondRandomUser);
        uint256 balanceWinnerBefore = cryptoBets.balances(randomUser);

        cryptoBets.resolveBet(0, 0);

        uint256 balanceLoserAfter = cryptoBets.balances(secondRandomUser);
        uint256 balanceWinnerAfter = cryptoBets.balances(randomUser);

        // Asserts
        assertEq(balanceLoserBefore, balanceLoserAfter);
        assert(balanceWinnerAfter - balanceWinnerBefore == 2 ether);


        vm.stopPrank();

    }

}