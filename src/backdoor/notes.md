
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
# Inheritance map
# flow diagram
# external functions (call path and authors), identify entry points.

# money variables
# gate variables

# LAYER 2
# define main external functions with the critical flow(go line by line), connect which contract calls which.
- walletRegistry
   proxyCreated(proxy, singleton, initializer)
        revert if token balance of the contract is not enougth
        walletAddress: address of a safe `proxy`
        revert if caller is not wallet factory
        revert if `singleton` is not same with the immutable singletonCopy
        revert if `initializer` bytes passed is not the setup.selector in Safe wallet
        threshold: the Safe wallet threshold
        revert if threshold is not equals the expected threshold = 1
        owners[]: get the token owners in the safe wallet 
        owners must be the expected = 1
        walletOwner: assign the first index in the owners[] array
        revert if walletOwner is not a beneficiary
        fallbackManager: getfallbackManager(wallet)
            get the 32 bytes from a defined slot
        revert if fallbackManager is not address (0)
        remove owner as beneficiary
        register the wallet under owners address
        pay tokens to newly created wallet "walletAddress"

- safe.sol
    setup(owners, threshold, to, data,)

# complete diagram

# AFTER LAYER 2: develop attacker mindset
# Read the docs and compare with your mental model
# questions 
1. what is the core invariants
2. what assumptions does this piece of code have, what does code believe is always true(trust assumptions)

# LAYER 3: Research
# find same case from similar protocols and study backward to compare 