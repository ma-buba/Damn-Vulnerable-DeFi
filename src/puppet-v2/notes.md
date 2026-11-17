
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
- puppetV2
borrow(borrowAmount)
    amount: calculateDepositOfWethRequired(tokenAmount)
        depositFactor: 3
        _getOracleQuote(tokenAmount)
            it gets the reserve and used it for price calculation
    pull the calculated weth amount from the caller to the contract 
    record the amount pulled in the deposit mappings for the caller 
    transfer the borrowed amount to the caller
    emit

WETH/PoolToken   =   10/100
Pool only has pool token, no weth     
    
# complete diagram

# AFTER LAYER 2: develop attacker mindset
# Read the docs and compare with your mental model
# questions 
1. what is the core invariants
2. what assumptions does this piece of code have, what does code believe is always true(trust assumptions)

# LAYER 3: Research 
# find same case from similar protocols and study backward to compare 