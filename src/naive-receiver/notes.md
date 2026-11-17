
**MY HACKING LAYOUT**

# LAYER 1 (open main contract that users interact with)
# imports
- NaiveReceiverPool
    **inherits**
    IERC3156FlashLender: Interface of the ERC-3156 FlashLender
    multicall: send bunch of delegate calls at once

    flashLoanReceiver: receiver of the loan that implement `onFlashLoan()` logic
    IERC3156FlashBorrower: Interface of the ERC-3156 FlashBorrower
    WETH: ERC20 already named to WETH

- BasicForwarder
    **inherits**
    EIP712: type structured data hashing and signing

    Address: collection of function related to the address type e.g calls and delegatecalls
    ECDSA: digital signature operations, such as tryrecover

# Inheritance map
# flow diagram
# external functions (call path and authors)
- NaiveReceiverPool
    flashLoan(receiver, token, amount, data)
        revert if token is not WETH
        transfer to receiver the amount of token
        deduct amount from totalDeposits variable
        call onFlashLoan from receiver contract, must return `keccak256("ERC3156FlashBorrower.onFlashLoan")`
        pull out amount + fixed fee from receiver to the contracts
        add to totalDeposit var, amount + fee
        add the fixed fee to the deposits mapping -> feeReceiver
        return true
    deposit()
        deposit ETH to the WETH token and get same amount of WETH minted
        add amount to the deposits mapping -> caller
        add amount to the totalDeposit var
    withdraw(amount, receiver)
        reduce amount from the deposits mapping -> caller
        reduce amount from totalDeposits var
        transfer amount to receiver

- BasicForwarder
    execute(request, signature)
        checkRequest(request, signature)
            revert if value in request is not msg.value
            revert if timestamp has passed deadline
            revert if nonce in request is not the same with nonce in mappinng
            revert if the address of the trustforwarder in the target is not this contract
            get signer, from ECDSA request hash and signature
            revert if from in the request is not the signer
        increase nonce in the nonce mapping
        get value from request in wei
        get target from request
        get payload, by packing data in request and from address in request
        get forwardGas, from request
        assembly:
            send a low level call to the target, using data in request as the calldata
            get the remaining gas available
        if remaining gas < the gas in request / 63 
        revert and burn gas(INVALID)
# money variables
# gate variables

# LAYER 2
# define main external functions with the critical flow(go line by line)
# complete diagram

# AFTER LAYER 2: develop attacker mindset
# Read the docs and compare with your mental model
# questions 
1. what is the core invariants
2. what assumptions does this piece of code have, what does code believe is always true(trust assumptions)

# LAYER 3: Research
# find same case from similar protocols and study backward to compare 