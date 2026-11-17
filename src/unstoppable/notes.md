
**MY HACKING LAYOUT**

# LAYER 1 (open main contract that users interact with)
# imports
- UnstoppableVault
    **inherits:**
    IERC3156FlashLender: Interface of the ERC-3156 FlashLender
    ReentrancyGuard:
    Owned: basically ownable contract
    ERC4626: vault holding one asset, issuing one share token that represents a proportional claim on the vault's total assets. The share price 
        floats based on `totalAssets / totalSupply`.
    Pausable: 

    ERC20: 
    FixedPointMathLib: Arithmetic library with operations for fixed-point numbers.
    SafeTransferLib: SafeTransferLib is Solmate's gas-optimized equivalent of SafeERC20.
    IERC3156FlashBorrower: Interface of the ERC-3156 FlashBorrower.
- UnstoppableMonitor
    **inherits:**
    Owned: basically ownable contract
    IERC3156FlashBorrower: Interface of the ERC-3156 FlashBorrower

    UnstoppableVault
    ERC20
# Inheritance map
# flow diagram
# external functions (call path and authors)
# money variables
# gate variables

# LAYER 2
# define main external functions with the critical flow(go line by line)
- UnstoppableVault:
    flashloan(receiver, token, amount, data)
        amount must not 0
        token must match the supported asset
        get balanceBefore, balance of totalAsset
        supply of assets and the shares must be the same
        transfer the loan to the receiver
        get the feee, there's a grace of 30 days you can take loan for free
        onFlashLoan on the receiver function must return `keccak256("IERC3156FlashBorrower.onFlashLoan")`
        pull amount + fee from receiver
        transfer the fee to the feeRecipient
        return true
- UnstoppableMonitor:
    onFlashLoan(initiator, token, amount, fee, calldata)
        revert if the initiator is not address(this) or caller is not the vault or token is not the asset of the vault or fee is not 0
        so fee must be 0
        approve vault to remove amount 
        return `keccak256("IERC3156FlashBorrower.onFlashLoan")`
    checkFlashLoan(amount) only owner
        amount must > 0
        get the asset, asset of the vault
        try:
            call `flashLoan(this, asset, amount, bytes(""))` 
            emit if passes
        catch:
            if failed emit flashLoan (false)
            pause the vault
            transferOwnership to the owner of the monitor to review the vault
# complete diagram

# AFTER LAYER 2: develop attacker mindset
# Read the docs and compare with your mental model
# questions 
1. what is the core invariants
2. what assumptions does this piece of code have, what does code believe is always true(trust assumptions)

# LAYER 3: Research
# find same case from similar protocols and study backward to compare 