
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
- SimpleGovernance
user ---> queueAction ---> executeAction
- SelfiePool
user ---> flashloan 
governance ---> emergencyExit  
# money variables
# gate variables

# LAYER 2
# define main external functions with the critical flow(go line by line), connect which contracts calls which.
- SimpleGovernance
queueAction(target, value, data)
	revert if caller has not enough votes:
		balance: current number of votes account has.
		halfTotalSupply: half totalsupply of the voting token
		return true, if balance > halftotalsupply, false otherwise
	revert if address(this) == target
	revert if data is 0 and target has no code
	actionId: equals actionCounter
	set `actions` mapping, for actionId 
	unchecked: increment actionCounter
	emit
executeAction(actionId)
	revert if Action Id cannot be executed:
		actionToExecute: get the action to execute based on actionId, from actions mapping
			if proposedAt = 0, return false.
		timeDelta:
		unchecked: minus proposedAt from block.timestamp, set as timeDelta
		return true, if executedAt = 0 and also timeDelta > 2 days
	actionToExecute: access action mappings through actionId
	set executedAt to block.timestamp
	emit
	functionCallWithValue(target, data, value)
		lowlevel call to the target contract.
	return the returnedData

- SelfiePool
flashloan(receiver, token, amount, data)
	token must be a supported currency
	transfer amount to receiver
	revert if onFlashloan didn't return this `CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");`
	revert if couldn't remove token from receiver to address(this)
	return true
emergencyExit(receiver)
	amount: token balanceOf address(this)
	transfer amount to receiver
	emit
	
# complete diagram

# AFTER LAYER 2: develop attacker mindset
# Read the docs and compare with your mental model
# questions 
1. what is the core invariants
2. what assumptions does this piece of code have, what does code believe is always true(trust assumptions)

# LAYER 3: Research
# find same case from similar protocols and study backward to compare 