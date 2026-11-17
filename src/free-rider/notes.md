
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
- recoveryManager
onERC721Received(tokenId, data)
	revert if caller is not the NFT  
	revert if beneficiary did not originated the call
	revert if tokenId > 5
	revert if the owner of the NFT Id is not this address
- NFTMarketPlace
OfferMany(tokenIds[], prices[])
	amount: length of tokens Ids 
	revert if amount is 0
	if amount if not the same with price length revert
	loop:
		keep calling OfferOne with the like of token Ids and prices
	OfferOne(tokenId, price)
		_token: get token for gas savings
		revert if price is 0
		revert if caller is not the owner of the token Id
		revert if approval is not granted by the owner
		record in the mapping the price of offer
		increment offerCount 
		emit
buyMany(tokenIds[])
	loop through buyOne(tokenId)
	buyOne() 
		priceToPay = get the price from the offers mapping
		revert if price to pay is 0
		revert if msg.value < priceToPay
		decrement offerCount
		_token: get the token for gas savings
		pull out token from owner to caller/buyer
		send priceToPay ETH amount to the owner of the token
		emit

WETH/PoolToken = 9000/15000

# complete diagram

# AFTER LAYER 2: develop attacker mindset
# Read the docs and compare with your mental model
# questions 
1. what is the core invariants
2. what assumptions does this piece of code have, what does code believe is always true(trust assumptions)

# LAYER 3: Research
# find same case from similar protocols and study backward to compare 