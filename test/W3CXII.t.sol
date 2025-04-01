// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "forge-std/Test.sol";
import "../src/W3CXII.sol";

contract W3CXII_Test is Test {
    W3CXII public w3cxii;
    address user1 = address(1);
    address user2 = address(2);
    address attacker = address(3);

    function setUp() public {
        w3cxii = new W3CXII{value: 0.5 ether}();
    }

    // Test constructor
    function test_Constructor() public view {
        assertEq(address(w3cxii).balance, 0.5 ether);
    }

    // Test deposit function
    function test_Deposit() public {
        vm.prank(user1);
        vm.deal(user1, 1 ether);
        w3cxii.deposit{value: 0.5 ether}();
        
        assertEq(w3cxii.balanceOf(user1), 0.5 ether);
        assertEq(address(w3cxii).balance, 1 ether);
    }

    function test_Deposit_RevertIfInvalidAmount() public {
        vm.prank(user1);
        vm.deal(user1, 1 ether);
        
        vm.expectRevert("InvalidAmount");
        w3cxii.deposit{value: 0.4 ether}();
    }

    function test_Deposit_RevertIfMaxDepositExceeded() public {
        vm.startPrank(user1);
        vm.deal(user1, 2 ether);
        w3cxii.deposit{value: 0.5 ether}();
        w3cxii.deposit{value: 0.5 ether}();
        
        vm.expectRevert("Max deposit exceeded");
        w3cxii.deposit{value: 0.5 ether}();
        vm.stopPrank();
    }

    function test_Deposit_RevertIfDepositLocked() public {
        // Fill contract to 1.5 ether (0.5 from constructor + 1 from deposit)
        vm.prank(user1);
        vm.deal(user1, 1 ether);
        w3cxii.deposit{value: 0.5 ether}();
        
        vm.prank(user2);
        vm.deal(user2, 1 ether);
        w3cxii.deposit{value: 0.5 ether}();
        
        // Next deposit should lock (total balance would be >= 2 ether)
        vm.prank(attacker);
        vm.deal(attacker, 0.5 ether);
        vm.expectRevert("deposit locked");
        w3cxii.deposit{value: 0.5 ether}();
    }

    // Test withdraw function
    function test_Withdraw() public {
        // Setup deposit
        vm.prank(user1);
        vm.deal(user1, 1 ether);
        w3cxii.deposit{value: 0.5 ether}();
        
        uint initialBalance = user1.balance;
        
        // Withdraw
        vm.prank(user1);
        w3cxii.withdraw();
        
        assertEq(w3cxii.balanceOf(user1), 0);
        assertEq(user1.balance, initialBalance + 0.5 ether);
    }

    function test_Withdraw_RevertIfNoDeposit() public {
        vm.prank(user1);
        vm.expectRevert("No deposit");
        w3cxii.withdraw();
    }

    function test_Withdraw_EdgeCase_Exactly1EtherDeposit() public {
        // User deposits exactly 1 ether (in two transactions)
        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        w3cxii.deposit{value: 0.5 ether}();
        w3cxii.deposit{value: 0.5 ether}();
        
        // Should not revert
        w3cxii.withdraw();
        vm.stopPrank();
        
        assertEq(w3cxii.balanceOf(user1), 0);
    }

    function test_Withdraw_EdgeCase_Exactly20EtherBalance() public {
        // First make the deposit
        vm.prank(user1);
        vm.deal(user1, 1 ether);
        w3cxii.deposit{value: 0.5 ether}();
        
        // Then set exactly 20 ether balance
        vm.deal(address(w3cxii), 20 ether);
        
        // Withdraw should set dosed
        vm.prank(user1);
        w3cxii.withdraw();
        
        assertTrue(w3cxii.dosed());
    }

    function test_Dest() public {
        // First make the deposit
        vm.prank(user1);
        vm.deal(user1, 1 ether);
        w3cxii.deposit{value: 0.5 ether}();
        
        // Then set exactly 20 ether balance
        vm.deal(address(w3cxii), 20 ether);
        
        // Withdraw to set dosed state
        vm.prank(user1);
        w3cxii.withdraw();
        
        // Verify dosed state is set
        assertTrue(w3cxii.dosed());
        
        // Test dest
        uint contractBalance = address(w3cxii).balance;
        uint userInitialBalance = user1.balance;
        vm.prank(user1);
        w3cxii.dest();
        
        // After dest(), all contract balance should be sent to user1
        assertEq(user1.balance, userInitialBalance + contractBalance);
    }

    function test_Dest_RevertIfNotDosed() public {
        vm.prank(user1);
        vm.expectRevert("Not dosed");
        w3cxii.dest();
    }

    function test_Withdraw_SetsDosedIfBalanceOver20Eth() public {
        // First make the deposit
        vm.prank(user1);
        vm.deal(user1, 1 ether);
        w3cxii.deposit{value: 0.5 ether}();
        
        // Then increase balance to trigger dosed state
        vm.deal(address(w3cxii), 20 ether);
        
        // Withdraw
        vm.prank(user1);
        w3cxii.withdraw();
        
        assertTrue(w3cxii.dosed());
        assertEq(w3cxii.balanceOf(user1), 0.5 ether); // Balance not reset when dosed
    }

    function test_Withdraw_TransferFailure() public {
        // Setup deposit for reverting contract
        address revertingContract = address(new RevertingContract());
        vm.deal(revertingContract, 1 ether);
        vm.prank(revertingContract);
        w3cxii.deposit{value: 0.5 ether}();
        
        // Try to withdraw to reverting contract
        vm.prank(revertingContract);
        vm.expectRevert("Transfer failed");
        w3cxii.withdraw();
    }

    // Modified test to handle direct ether transfers through the constructor
    function test_DirectEtherTransferViaConstructor() public {
        // Create a new contract with 1 ether
        W3CXII newContract = new W3CXII{value: 1 ether}();
        
        // Assert that the contract received the ether
        assertEq(address(newContract).balance, 1 ether);
    }
}

// Contract that reverts on receive
contract RevertingContract {
    receive() external payable {
        revert("Transfer failed");
    }
}