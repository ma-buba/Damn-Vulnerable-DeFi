
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
- trustfulOracle
initializerRole ---> setInitialPrices
trustedSourcedRole ---> postPrice
- Exchange
user ---> buyOne ---> sellOne
# money variables
# gate variables

# LAYER 2
# define main external functions with the critical flow(go line by line), connect which contract calls which.
- trustfulOracle
    setInitialPrices(sources[], symbols[], prices[])
        only initializer role can call
        length of all arrays must be the same
        loop:
            unchecked
            setPrice(sources[i], symbols[i], prices[i])
            increment i
        renounceRole, initializer can only set once and the role is revoked
        
        # To confirm
        seems like oracle it self will be the msg.sender in the renounceRole.
    postPrice(symbol, newPrice)
        only trusted sourced role can call, will be able to change price of the source themselves.
        just like updating price on and on.
        _setPrice(msg.sender, symbol, newPrice):
            oldPrice: get value from _priceBySourced mapping
            set the mapping to the newPrice
            emit

- trustfulOracleInitializer
    deploys trustfulOracle
    set the initial prices
    emit

- Exchange
    buyOne()
        revert if msg.value is 0
        price: get median price from oracle, based on symbol
        revert if msg.value < price
        id: safe mint to caller the NFT and return the id
        unchecked: if caller pay over the price, remove the price and return the rest.
        emit
    sellOne()
        revert if caller is not the owner of token id
        revert if address(this) is not approved for pulling out tokens
        price: get median price from oracle, based on symbol.
        revert if the ETH balance of this address < price
        pull the token from caller to this address
        burn the token
        send the caller the price(ETH)
        emit
# complete diagram

# AFTER LAYER 2: develop attacker mindset
# Read the docs and compare with your mental model
# questions 
1. what is the core invariants
2. what assumptions does this piece of code have, what does code believe is always true(trust assumptions)

# LAYER 3: Research
# find same case from similar protocols and study backward to compare 