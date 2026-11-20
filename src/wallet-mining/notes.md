
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
- WalletDeployer 
	rule(_mom)
		revert if caller is not cheif, or if _mom is address 0, or if mom is not address 0.
		set mom
	drop(aim, wat, num)
		return false, if mom is not address 0 & can(caller, aim) is false.
			can(msg.sender, aim):
				make a function call "can(address, address)" to the mom stored in the variable.
		return false, if a "createProxyWithNonce" call to the safeproxy doesn't return == `aim`.
		if token balance of the address > 1 ether: transfer to the caller 1 ether.
		return true

- TransparentProxy
- admin control upgrader, upgrader can set a new implementation to the proxy
	setUpgrader(who)
		only admin can set upgrader

- AuthorizerFactory
	deployWithProxy(wards[], aims[], upgrader[])
		authorizer: deploys a proxy and it's implementation
		assert(needsInit in the authorizer == 0)
		setUpgrader in the authorizer

- AuthorizerUpgradeable
	Init(wards[], aims[])
		needsInit but not be 0, if it's 0 revert
		loop:
			set wards and aims in the `wards` mapping to 1
		needsInit = 0
	can(usr, aim)
		returns true if wards and aim in the `wards` mapping is set to 1



# complete diagram

# AFTER LAYER 2: develop attacker mindset
# Read the docs and compare with your mental model
# questions 
1. what is the core invariants
2. what assumptions does this piece of code have, what does code believe is always true(trust assumptions)

# LAYER 3: Research
# find same case from similar protocols and study backward to compare 