
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
- Reentrancy guard 
# Inheritance map
# flow diagram
# external functions (call path and authors), identify entry points.
user ---> borrow
# money variables
# gate variables

# LAYER 2
# define main external functions with the critical flow(go line by line), connect which contract calls which.
- puppet.sol
    borrow(amount, recipient)
        depositReq: 
            calculatedepreq
            get the ETH/poolToken price, multiply by amount, the DEPOSIT FACTOR = 2, which will make the req deposit twice the amount to borrow
        revert if ETH deposited is < depositreq
        if >, send value - depositreq(refund the rest and take only the deposit req)
        increment to deposits mapping for the caller/user
        transfer amount to recipient 
        revert if failed, emit.
# complete diagram

# AFTER LAYER 2: develop attacker mindset
# Read the docs and compare with your mental model
# questions 
1. what is the core invariants
2. what assumptions does this piece of code have, what does code believe is always true(trust assumptions)

# LAYER 3: Research
# find same case from similar protocols and study backward to compare 