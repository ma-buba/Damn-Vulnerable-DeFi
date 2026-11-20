# Damn Vulnerable Defi
1. Unstoppable:
a check that compare prices, rejects if asset is more than the share ever minted
so this failed by gifting the contract some tokens, so the check will always failed

2. Naive Receiver:
sent a signed call to basicForwarder contract about naivereceiver pool to make withdrawals.
it is able to be bypassed by a check that if a call comes from basic forwarder theres a 20 bytes a the last to be mixed with the calldata.
`request.from == signer` this identify who makes the call, and deduct from his balance.
this is also able to be bypassed through the multicall that is signed to the basic forwarder, in which withdraw is part of the calldata, and it checks the last 20 bytes address, but where the address is merged is bypassed.
had it been i called withdraw through the basic forwarder, but multicall is called/pass.

we sign standard ethereum hash struct using `solady` library

```solidity
   bytes32 digest = keccak256(
      abi.encodePacked("\x19\x01", forwarder.domainSeparator(), forwarder.getDataHash(request))
   );

   (uint8 v, bytes32 r, bytes32 s) = vm.sign(playerPk, digest);
```


3. truster:
flashloan make a call to the target, which is the receiver, which transfers the amount.
but the amount also lack a zero check and also the token has been passed as the target in which approve also is passed as the data.
so the flashloan contract is forced to make approval for the player to remove the tokens.

```solidity 
target.functionCall(data);
``` 
is functionCall a built in function in solidity address that make low level calls.



4. SideEntranceLenderPool:
I used an EOA delegated to a malicious contract. When I called flashLoan, it invoked execute() in my malicious contract. I then deposited the borrowed funds back into the same flash loan provider, which allowed the post-loan check to pass. However, since the mapping recorded that I had deposited the funds, I was able to withdraw them and send them to the recovery address.




5. The Rewarder:
### reading json file or any file as string
```solidity
function readFile(string calldata path) external view returns (string memory);
```

```solidity
vm.readFile(string.concat(vm.projectRoot(), path))
```

# input
path: the absolute path to a file on disk
"/home/ma_buba/dvd/test/the-rewarder/dvt-distribution.json"

# returns
string: the raw contents of the file, as a UTF-8 string
'[{"beneficiary":"0x...","amount":"1000"}, ...]'

# In production	                                             In local testing
JSON lives off-chain (IPFS, website, GitHub)	               You download it to your machine
Merkle tree built off-chain (JS/Rust)	                     You build it locally (Murky in Solidity, or JS)
Proofs computed off-chain	                                 You compute them locally
Only the root goes on-chain	                              You either hardcode the root or compute it locally
Users submit proofs via frontend	                           You submit proofs via your test/script

Yes — for local testing, you download the JSON first, then read it locally.


### encoding json string 
```solidity
function parseJson(string calldata json) external pure returns (bytes memory);
```

```solidity
vm.parseJson(vm.readFile(string.concat(vm.projectRoot(), path)))
```

# input 
json: a string containing json text
'[{"beneficiary":"0xAAA...","amount":"1000"}, {"beneficiary":"0xBBB...","amount":"500"}]'
it takes only the values and not the keys.

# returns
bytes: the JSON converted into ABI-encoded bytes
it doesn't return a typed array, it returns raw bytes that you must decode.

### difference between vm.parseJSON and manual encoding
1. vm.parseJson — you give it JSON text with keys, and it handles the keys and type conversions for you, returning ABI bytes ready to decode.
2. Raw abi.encode — you must already have the values as Solidity variables (seperate with the keys). You do the extraction, conversion, and packing yourself.



### decoding the addresses and amounts of the claimers
```solidity
abi.decode(bytes memory encodedData, (Type1, Type2, ...)) returns (Type1, Type2, ...);
```
# input
encodedData: the ABI-encoded bytes
A tuple of types: what you want to decode them into

# returns
a decoded values in the type you specified

```solidity
struct Reward {
   address beneficiary;
   uint256 amount;
}
abi.decode(vm.parseJson(vm.readFile(string.concat(vm.projectRoot(), path))), (Reward[]))
```

- A Merkle proof lets me recompute the root by walking from my leaf to the top, using the sibling hashes the proof gives me — the same process as building the tree, just for one path.
```solidity
proof: merkle.getProof(wethLeaves, 2) // Alice's address is at index 2
```
using MURKY's merkle library


# vulnerability
The distributor groups repeated claims of the same token and only checks the "already claimed" bitmap once at the end of the group — so the same claim can be replayed N times in a single call before the bitmap is updated.


7. Compromised
The web service's HTTP response body leaked 3 private keys — double-encoded `(hex → ASCII(Base64 string) → 0x... keys).`
Those keys belong to the 3 trusted reporters of TrustfulOracle.

`postPrice()` is gated only by onlyRole(TRUSTED_SOURCE_ROLE) — if you have a reporter's key, you can set that source's price freely.

# how the median computation works 
I. Odd → just take the middle one (no addition).
II. Even → add the two middle ones and divide by 2.
but the array are then re-ordered, so i'll have to control every oracle to compromise.

# how to secure it 
# Architecture (biggest win)
- Web tier must hold zero signing keys — separate signing services with no public ingress.
- Keys in KMS/HSM/Vault; APIs return signatures, never key material.
- Least-privilege IAM; short-lived credentials.

# Code
- Allowlist DTOs / schema-first serializers — never SELECT * to a client.
- Treat *key*, *secret*, *token*, *password as never-serialized.
- No debug/env/config endpoints in prod; generic error pages.
- No secrets in frontend bundles (VITE_*, NEXT_PUBLIC_* are public).

# Artifacts / Infra
- .env, .git, *.pem, *.key, *.map never served or baked into images.
- Secret scanning in CI + pre-commit (gitleaks, trufflehog).
- Cache-Control: no-store on anything sensitive.
# Detection
- Log redaction at the logger; egress DLP for key-shaped strings.
- Key rotation playbook + audit trail.
- 
# HOW DO WE DECODE THE PRIVATE-KEY
The body isn't a single encoding — it's `hex → ASCII(Base64 string) → private key`. Each layer's output is the next layer's input.
- layer 1 (hex --->  ASCII(base64 string))
   every pair of the hex digits is one ASCII character.
   ```
   4d 48 67 33 5a 44 45 31 59 6d 4a 68 4d 6a 5a 6a 4e 54 49 7a 4e 6a 67 7a 59 6d 5a 6a 4d 32 52 6a 4e 32 4e 6b 59 7a 56 6b 4d 57 49 34 59 54 49 33 4e 44 51 30 4e 44 63 31 4f 54 64 6a 5a 6a 52 6b 59 54 45 33 4d 44 56 6a 5a 6a 5a 6a 4f 54 6b 7a 4d 44 59 7a 4e 7a 51 30
   ```   
   4d → 'M'
   48 → 'H'
   67 → 'g'
   33 → '3'
   5a → 'Z'
   44 → 'D'
   45 → 'E'
   31 → '1'.......

   layer 1 decodes to:
   `MHg3ZDE1YmJhMjZjNTIzNjgzYmZjM2RjN2NkYzVkMWI4YTI3NDQ0NDc1OTdjZjRkYTE3MDVjZjZjOTkzMDYzNzQ0`

- layer 2 (base64 ---> text)
   this decodes the base64 to the actual private-key

# SINGLE COMMAND LINE THAT DOES ALL THIS
```bash
echo "4d 48 67 33 5a 44 45 31 59 6d 4a 68 4d 6a 5a 6a 4e 54 49 7a 4e 6a 67 7a 59 6d 5a 6a 4d 32 52 6a 4e 32 4e 6b 59 7a 56 6b 4d 57 49 34 59 54 49 33 4e 44 51 30 4e 44 63 31 4f 54 64 6a 5a 6a 52 6b 59 54 45 33 4d 44 56 6a 5a 6a 5a 6a 4f 54 6b 7a 4d 44 59 7a 4e 7a 51 30" | xxd -r -p | base64 -d
```
What this does:
`echo "..."` prints the hex.
`xxd -r -p` converts the Hex to ASCII text (Layer 1).
`base64 -d` decodes that text from Base64 into the final private key (Layer 2).

##### the first decoding
```bash
ma_buba@DESKTOP-4JPC4VR:~/damn-vulnerable-defi$ echo "4d 48 67 33 5a 44 45 31 59 6d 4a 68 4d 6a 5a 6a 4e 54 49 7a 4e 6a 67 7a 59 6d 5a 6a 4d 32 52 6a 4e 32 4e 6b 59 7a 56 6b 4d 57 49 34 59 54 49 33 4e 44 51 30 4e 44 63 31 4f 54 64 6a 5a 6a 52 6b 59 54 45 33 4d 44 56 6a 5a 6a 5a 6a 4f 54 6b 7a 4d 44 59 7a 4e 7a 51 30
" | xxd -r -p | base64 -d
0x7d15bba26c523683bfc3dc7cdc5d1b8a2744447597cf4da1705cf6c993063744 ma_buba@DESKTOP-4JPC4VR:~/damn-vulnerable-defi$
```
##### the second decoding
```bash
ma_buba@DESKTOP-4JPC4VR:~/damn-vulnerable-defi$ echo "4d 48 67 32 4f 47 4a 6b 4d 44 49 77 59 57 51 78 4f 44 5a 69 4e 6a 51 33 59 54 59 35 4d 57 4d 32 59 54 56 6a 4d 47 4d 78 4e 54 49 35 5a 6a 49 78 5a 57 4e 6b 4d 44 6c 6b 59 32 4d 30 4e 54 49 30 4d 54 51 77 4d 6d 46 6a 4e 6a 42 69 59 54 4d 33 4e 32 4d 30 4d 54 55 35
" | xxd -r -p | base64 -d
0x68bd020ad186b647a691c6a5c0c1529f21ecd09dcc45241402ac60ba377c4159 ma_buba@DESKTOP-4JPC4VR:~/damn-vulnerable-defi$
``` 


13. wallet-mining:
- deploying contract using create2: The real thing. `create2(value, offset, size, salt)` is the actual CREATE2 opcode, and it runs inside `SafeProxyFactory.deployProxy`. So the address formula applies directly with the deployment.
- if i want to specifically calculate the formula for a deployed or ready to be deployed contract, i use this.
`address = keccak256(0xff ++ deployer ++ salt ++ keccak256(init_code))[12:]`
this returns 32 bytes, while the last 20 bytes is the predicted address of the contract.

`keccak256(abi.encodePacked(bytes1(0xff), deployer, salt, keccak256(initCode)));`