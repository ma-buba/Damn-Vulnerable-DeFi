
**MY HACKING LAYOUT**
Layer 1: Skim & Contextualize.
	Grab the big picture. Jump into the code. Not docs.
Layer 2: Deep Read & Memorize.
	Go line by line. Walk the entire flow in your head
	without looking at the screen
Layer 3: Research.
	This is where bugs actually live.
	NOW read the docs. Compare to reality.
	Study other protocols. Work backwards from failure modes

# LAYER 1 (open main contract that users interact with)
# imports
- TheRewarderDistributor.sol
    fixpointmathlib: arithmetic library
    safeTransferlib:
    IERC20:
    MerkleProof: for proving merkle trees
    BitMaps: store bool values in a gas efficient way, Each bit in a uint256 represents one boolean. 
# Inheritance map
# flow diagram
# external functions (call path and authors), identify entry points.
- TheRewarderDistributor.sol
    user ---> createDistributions() ---> claimRewards() ---> clean().
# money variables
# gate variables

# LAYER 2
# define main external functions with the critical flow(go line by line),connects which contracts call which.
- createDistributions(token, newRoot, amount)
    revert if amount is 0
    revert if newRoot is 0
    revert if remaining in the distribution mapping of the token is "not" 0.
    set remaining in the distribution mapping of the token, to `amount`
    batchNumber: from distributions.nextBatchNumber mapping, for the token.
    in distributions.roots of the nextBatchNumber, set newRoot
    increment nextBatchNumber in distributions mapping
    pull the token `amount` from caller to the contract
    emit
- clean(token[])
    for loop:
        get the token of i index.
        if remaining in the distribution mapping of the token is 0.
            transfer the whole balance of the contract to the owner
- claimRewards(inputClaims[], inputTokens[])
    create inputClaim
    create `token`
    create bitset, accumulator
    create amount
    loop to inputClaims length
        inputClaims: get the inputClaims of i index
        wordPosition = inputClaim.batchNumber / 256;
        bitPosition = inputClaim.batchNumber % 256;

        if the token is not equals inputTokens[index], token index in the inputClaims is used.
            if address of token is not 0
                if setClaim returned false revert
            set the token to inputTokens[index], token index in the inputClaims is used.
            set bitset to `1 << bitPosition`, set 1 at a given position
            set amount to the one in the inputClaim
        if the token is equal to inputTokens[index], token index in the inputclaims is used
            add bitset to 1 more at a given position
            increment amount with inputTokens.amount
        if we are on the last claim
            if setClaim returned false revert
            
        leaf: hash of sender and amount
        root: return the root for the batch number  
        revert if merkle proof in the inputClaim is not for the root and leaf
        transfer that token `amount` to the caller

- setClaimed(token, amount, wordPosition, newBits)
    currentWord: from claims mapping for the sender and word position
    if ((currentWord & newBits) != 0) return false;

    update the claims mapping for the sender and word position, currentWord | newBits
    deduct amount in distributions.remaining
    return true



# complete diagram

# AFTER LAYER 2: develop attacker mindset
# Read the docs and compare with your mental model
# questions 
1. what is the core invariants
2. what assumptions does this piece of code have, what does code believe is always true(trust assumptions)

# LAYER 3: Research
# find same case from similar protocols and study backward to compare 