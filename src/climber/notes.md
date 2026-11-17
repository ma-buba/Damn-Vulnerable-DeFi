
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
- ClimberVault
	initializer ---> initialize() 
	owner ---> withdraw()
	sweeper ---> sweepFunds()

# money variables
# gate variables

# LAYER 2
# define main external functions with the critical flow(go line by line), connect which contract calls which.
- ClimberVault
	initialize(admin, proposer, sweeper)
		the caller is the initial owner
		deploytimelock and give it the ownership
		setsweeper
		updateWithdrawaltimestamp
	withdraw(token, recipient, amount)
		revert if amount > 1 ether
		revert if it didn't pass the next 15 days withdrawal time
		update last withdrawal time
		transfer token amount to recipeint

- ClimberTimelock
	schedule(targets[], values[], dataElements[], salts)
		only proposer role can call
		revert if target is not within target count
		revert if targets and values length are not the same
		revert if dataElements and targets is not the same
		id: gets the Operation Id (keccak of the whole input params)
		revert if the operation state is not unknown
		in operation mappings based on the id, set the readyAtTimestamp = blocktimestamp + delay
		set known to true
	execute(targets[], values[], dataElements[], salts)
		revert if length of target is equals minimum 
		revert if target and values length is not the same
		revert if targets and dataElement lenght is not the same 
		id: gets the operation id
		loop:
			make the function call for all the targets, dataElement and values.
			revert if operation state for the id is not ready for execution 
			mark executed true in the operations mapping, for the id
# complete diagram

# AFTER LAYER 2: develop attacker mindset
# Read the docs and compare with your mental model
# questions 
1. what is the core invariants
2. what assumptions does this piece of code have, what does code believe is always true(trust assumptions)

# LAYER 3: Research
# find same case from similar protocols and study backward to compare 