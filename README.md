# Damn Vulnerable DeFi

Damn Vulnerable DeFi is _the_ smart contract security playground for developers, security researchers and educators.

Perhaps the most sophisticated vulnerable set of Solidity smart contracts ever witnessed, it features flashloans, price oracles, governance, NFTs, DEXs, lending pools, smart contract wallets, timelocks, vaults, meta-transactions, token distributions, upgradeability and more.

Use Damn Vulnerable DeFi to:

- Sharpen your auditing and bug-hunting skills.
- Learn how to detect, test and fix flaws in realistic scenarios to become a security-minded developer.
- Benchmark smart contract security tooling.
- Create educational content on smart contract security with articles, tutorials, talks, courses, workshops, trainings, CTFs, etc. 

---
## 👤 Author

**Muhammad Abdullah** (ma_buba)
- GitHub: [@ma-buba](https://github.com/ma-buba)
- Twitter/X: [@0xstrikerr](https://twitter.com/0xstrikerr)
- LinkedIn: [Muhammad Abdullah](https://linkedin.com/in/muhammadd-abdullahii-3a5774306)
> Built while learning smart contract security. Feedback and PRs welcome — if you spot a cleaner exploit, open an issue! 🐛
---
### ⭐ If this helped you understand a challenge, consider starring the repo!

## Challenge Progress

**Solved: 12 / 18**

- [✅] 01 - Unstoppable
- [✅] 02 - Naive Receiver
- [✅] 03 - Truster
- [✅] 04 - Side Entrance
- [✅] 05 - The Rewarder
- [✅] 06 - Selfie
- [✅] 07 - Compromised
- [✅] 08 - Puppet
- [✅] 09 - Puppet V2
- [✅] 10 - Free Rider
- [✅] 11 - Backdoor
- [✅] 12 - Climber
- [✅] 13 - Wallet Mining
- [ ] 14 - Puppet V3
- [ ] 15 - ABI Smuggling
- [ ] 16 - Shards
- [ ] 17 - Curvy Puppet
- [ ] 18 - Withdrawal


## Install

1. Clone the repository.
2. Checkout the latest release (for example, `git checkout v4.1.0`)
3. Rename the `.env.sample` file to `.env` and add a valid RPC URL. This is only needed for the challenges that fork mainnet state.
4. Either install [Foundry](https://book.getfoundry.sh/getting-started/installation), or use the [provided devcontainer](./.devcontainer/) (In VSCode, open the repository as a devcontainer with the command "Devcontainer: Open Folder in Container...")
5. Run `forge build` to initialize the project.

## Usage

Each challenge is made up of:

- A prompt located in `src/<challenge-name>/README.md`.
- A set of contracts located in `src/<challenge-name>/`.
- A [Foundry test](https://book.getfoundry.sh/forge/tests) located in `test/<challenge-name>/<ChallengeName>.t.sol`.

To solve a challenge:

1. Read the challenge's prompt.
2. Uncover the flaw(s) in the challenge's smart contracts.
3. Code your solution in the corresponding test file.
4. Try your solution with `forge test --mp test/<challenge-name>/<ChallengeName>.t.sol`.

> In challenges that restrict the number of transactions, you might need to run the test with the `--isolate` flag.

If the test passes, you've solved the challenge!

Challenges may have more than one possible solution.

### Rules

- You must always use the `player` account.
- You must not modify the challenges' initial nor final conditions.
- You can code and deploy your own smart contracts.
- You can use Foundry's cheatcodes to advance time when necessary.
- You can import external libraries that aren't installed, although it shouldn't be necessary.

## Troubleshooting

You can ask the community for help in [the discussions section](https://github.com/theredguild/damn-vulnerable-defi/discussions).

> This is my personal set of solutions to **Damn Vulnerable DeFi**, created by [The Red Guild](https://github.com/theredguild/damn-vulnerable-defi). All credit for the challenges goes to the original authors and contributors.

## Disclaimer

All code, practices and patterns in this repository are DAMN VULNERABLE and for educational purposes only.

DO NOT USE IN PRODUCTION.
