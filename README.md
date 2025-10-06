# Complete Guide: Creating and Deploying a Unique Drosera Trap

## Introduction

This guide walks you through creating, deploying, and publishing a unique Drosera trap on Ubuntu VPS using Termius.
You can reference [my trap](https://github.com/Idle0x/block-time-anomaly-trap) or [Drosera examples](https://github.com/drosera-network/examples/tree/main/defi-automation) for structure, but your implementation must be unique.

---

## How This Guide Works

**Commands & Files**: Copy commands exactly as shown. When you see `nano filename.sol`, you'll paste code and save with `Ctrl+X`, `Y`, `Enter`.

**AI Tools**: Use ChatGPT or Claude AI throughout - they'll generate your contracts, fix errors, and answer questions.

**Optional Steps**: Marked as (OPTIONAL). Skip if you want the quickest path.

**Prerequisites**:
- Ubuntu VPS with Termius access
- GitHub account
- Ethereum wallet with private key (Hoodi testnet)
- ChatGPT or Claude AI access
- Cadet and Corporal roles
- [Drosera operator running](https://github.com/izmerGhub/Drosera-Hoodi-Guide-Setup--Izmer?tab=readme-ov-file#2-drosera-operator-setup)

---

## Sergeant and Captain Roles

**Requirements**: 
- Unique trap concept
- Deploy
- Publish to GitHub
- Open a ticket and submit

You must have Cadet and Corporal roles first.

---

## ⚠️ CRITICAL: Your Trap Must Be UNIQUE

This is NOT a copy-paste tutorial. You must create something original that detects a different anomaly than existing traps.

---

## Part 1: Creating Your Trap

### Step 1: Project Setup

```bash
mkdir ~/my-unique-trap
cd ~/my-unique-trap
forge init
rm src/Counter.sol script/Counter.s.sol test/Counter.t.sol
```

---

### Step 2: Install Dependencies

```bash
# Install Foundry (if needed)
curl -L https://foundry.paradigm.xyz | bash
source ~/.bashrc
foundryup

# Install libraries
forge install foundry-rs/forge-std@v1.8.2
forge install OpenZeppelin/openzeppelin-contracts@v5.0.2

# Create ITrap interface
mkdir -p lib/drosera-contracts/interfaces
nano lib/drosera-contracts/interfaces/ITrap.sol
```

Paste:
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITrap {
    function collect() external view returns (bytes memory);
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory);
}
```
Save and exit with `Ctrl+X`, `Y`, `Enter`.

Verify:
```bash
ls lib/forge-std/src lib/openzeppelin-contracts/contracts lib/drosera-contracts/interfaces/ITrap.sol
```

---

### Step 3: Generate Your Contracts with AI

**This is the most important step.** You'll use AI to create all three contract files.

#### A. Get Example Contracts (Required - 2 minutes)

1. Visit [my trap](https://github.com/Idle0x/block-time-anomaly-trap) or [Drosera examples](https://github.com/drosera-network/examples/tree/main/defi-automation)
2. Pick ANY trap example (doesn't matter which)
3. Copy the trap contract from `src` folder
4. Copy the response contract from `src` folder

**Why required**: Without examples, AI won't generate Drosera-compatible code and your contracts won't compile.

#### B. Use This AI Prompt

Copy everything below, add your example contracts at the end, and paste to ChatGPT or Claude:

```
I need a UNIQUE Drosera trap for Hoodi testnet blockchain anomaly detection.

TASK:
1. Suggest 3-5 UNIQUE trap ideas (avoid common ones like simple gas monitoring)
2. For each idea provide: description, data points, trigger conditions, response action, detection approach (straightforward/moderate/advanced)
3. Once I choose, generate THREE files with these EXACT names:
   - MyUniqueTrap.sol
   - MyUniqueResponse.sol  
   - Deploy.sol

CRITICAL NAMING: Use exactly "MyUniqueTrap" and "MyUniqueResponse" as contract names in ALL files including Deploy.sol imports. DO NOT use custom names like "GasTrap". This prevents compilation errors.

REQUIREMENTS:
- Trap implements ITrap from "drosera-contracts/interfaces/ITrap.sol"
- collect(): view, returns bytes memory
- shouldRespond(): pure (no state/external calls), returns (bool, bytes memory)
- Response function signature matches shouldRespond() payload
- Solidity ^0.8.20
- Complete, compilable, functional

UNIQUENESS: Suggest creative ideas - cross-protocol anomalies, statistical patterns, multi-condition triggers, uncommon data combinations, novel threats, DeFi edge cases.

EXAMPLE TRAP (for structure only - make mine unique):
[PASTE YOUR EXAMPLE TRAP CONTRACT HERE]

EXAMPLE RESPONSE (for structure only):
[PASTE YOUR EXAMPLE RESPONSE CONTRACT HERE]

Start with 3-5 unique ideas.
```

#### C. Choose and Save

1. Review AI's suggestions, pick one
2. AI generates all three files
3. Ask for changes if needed
4. Save the code - you'll paste it in Step 4

See [troubleshooting](#troubleshooting) for trap requirements.

---

### Step 4: Create Files

#### Source Contracts

```bash
mkdir -p src
nano src/MyUniqueTrap.sol
```
Paste your AI-generated trap contract. Save and exit with `Ctrl+X`, `Y`, `Enter`.

```bash
nano src/MyUniqueResponse.sol
```
Paste your AI-generated response contract. Save and exit with `Ctrl+X`, `Y`, `Enter`.

#### Deployment Script

```bash
mkdir -p script
nano script/Deploy.sol
```
Paste your AI-generated deployment script. Save and exit with `Ctrl+X`, `Y`, `Enter`.

#### Test File (OPTIONAL)

```bash
mkdir -p test
nano test/MyUniqueTrap.t.sol
```
Paste AI-generated tests or leave placeholder. Save and exit.

#### Configuration Files

**foundry.toml**:
```bash
nano foundry.toml
```
```toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
solc = "0.8.20"
```
Save and exit with `Ctrl+X`, `Y`, `Enter`.

**remappings.txt**:
```bash
nano remappings.txt
```
```
drosera-contracts/=lib/drosera-contracts/
forge-std/=lib/forge-std/src/
openzeppelin-contracts/=lib/openzeppelin-contracts/
@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/
ds-test/=lib/openzeppelin-contracts/lib/forge-std/lib/ds-test/src/
erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/
halmos-cheatcodes/=lib/openzeppelin-contracts/lib/halmos-cheatcodes/src/
```

**drosera.toml**:
```bash
nano drosera.toml
```
```toml
ethereum_rpc = "https://rpc.hoodi.ethpandaops.io/"
drosera_rpc = "https://relay.hoodi.drosera.io"
eth_chain_id = 560048
drosera_address = "0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D"

[traps]
[traps.my_unique_trap]
path = "out/MyUniqueTrap.sol/MyUniqueTrap.json"
response_contract = "UPDATE_AFTER_DEPLOYMENT"
response_function = "yourResponseFunction(string,uint256)"
cooldown_period_blocks = 33
min_number_of_operators = 1
max_number_of_operators = 3
block_sample_size = 10
private = true
whitelist = ["0xYOUR_WALLET_ADDRESS"]
private_trap = true
address = "UPDATE_AFTER_DEPLOYMENT"
```
Update `response_function` to match your response contract. Update addresses and whitelist after deployment. Save and exit with `Ctrl+X`, `Y`, `Enter`..

#### Repository Files

**.gitignore**:
```bash
nano .gitignore
```
```
out/
cache/
broadcast/
.env
.vscode/
.idea/
.DS_Store
```

**README.md**:
```bash
nano README.md
```
```markdown
[Generate readme in the same AI session you're working in.]```

**Deployment docs** (OPTIONAL): Create `deployment/DEPLOYMENT.md`, `deployment/addresses.json`, `deployment/TRANSACTIONS.md` if you want detailed records.

---

### Step 5: Compile

```bash
forge build
```

Check artifacts exist:
```bash
ls out/MyUniqueTrap.sol/MyUniqueTrap.json out/MyUniqueResponse.sol/MyUniqueResponse.json
```

**If errors**: Copy full error to ChatGPT/Claude or post in [#technical Discord](https://discord.com/invite/drosera).

---

### Step 6: Environment Setup

```bash
nano .env
```
```
PRIVATE_KEY=0xYOUR_PRIVATE_KEY_HERE
GITHUB_TOKEN=ADDED_IN_PART_2
```
Replace with your actual private key. Save and exit with `Ctrl+X`, `Y`, `Enter`.

```bash
chmod 600 .env
```

---

### Step 7: Deploy

Ensure your operator is running. You have already done this from the [cadet and corporal part](https://github.com/0xmoei/Drosera-Network?tab=readme-ov-file#method-1-docker).

```bash
source .env
export PRIVATE_KEY=$PRIVATE_KEY
forge script script/Deploy.sol --rpc-url https://rpc.hoodi.ethpandaops.io --private-key $PRIVATE_KEY --broadcast
```

Note your addresses:
```
Trap deployed at: 0x...
Response deployed at: 0x...
```

Update drosera.toml:
```bash
nano drosera.toml
```
Replace:
- `response_contract = "0xYOUR_RESPONSE_ADDRESS"`
- `address = "0xYOUR_TRAP_ADDRESS"`
- `whitelist = ["0xYOUR_WALLET_ADDRESS"]`

**Note**: You can overwrite your existing Cadet/Corporal trap or create new (max 2 per wallet).

**If errors**: Paste to AI or ask in [Discord #technical](https://discord.com/invite/drosera).

---

### Step 8: Apply Trap

```bash
drosera dryrun
DROSERA_PRIVATE_KEY=your_private_key_here drosera apply --eth-rpc-url https://rpc.hoodi.ethpandaops.io
```

Replace `your_private_key_here` with your private key.

**Common issues**:
- "Maximum traps reached": You have 2 traps already - overwrite one or use new wallet
- Configuration errors: Paste error to AI for debugging
- If stuck after debugging: Trap might be too complex - simplify it

---

### Step 9: Test (OPTIONAL)

```bash
forge test -vv
cast call 0xYOUR_TRAP_ADDRESS "collect()(bytes)" --rpc-url https://rpc.hoodi.ethpandaops.io
```

---

## Part 2: Publishing to GitHub

### Step 1: Initialize and Commit

```bash
git init
git add README.md LICENSE foundry.toml drosera.toml remappings.txt .gitignore src/ script/ test/ deployment/
git submodule update --init --recursive
git add lib/forge-std lib/openzeppelin-contracts lib/drosera-contracts
git status  # Verify .env is NOT listed
git commit -m "Initial commit: [Your Trap Name]"
```

---

### Step 2: Create GitHub Repository

1. Go to [github.com/new](https://github.com/new)
2. Name: `my-unique-trap`
3. Public visibility
4. Don't initialize with README/license
5. Click "Create repository"
6. Copy URL from green "Code" button: `https://github.com/YOUR_USERNAME/my-unique-trap.git`

---

### Step 3: Generate GitHub Token

1. Go to [github.com/settings/tokens](https://github.com/settings/tokens)
2. "Generate new token (classic)"
3. Name: `my-unique-trap-token`
4. Scopes: **Both** `repo` AND `workflow`
5. Copy token: `ghp_XXXX...`

Add to .env:
```bash
nano .env
```
```
PRIVATE_KEY=0xYOUR_PRIVATE_KEY_HERE
GITHUB_TOKEN=ghp_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

---

### Step 4: Push to GitHub

```bash
git remote add origin https://github.com/YOUR_USERNAME/my-unique-trap.git
git remote -v  # Verify
source .env
git push -u origin main
```

Enter GitHub username and paste PAT when prompted.

Verify at `https://github.com/YOUR_USERNAME/my-unique-trap`

---

### Step 5: Cleanup

```bash
rm .env
ls -la | grep .env  # Verify removed
```

---

## Part 3: Submission

### Verify Trap Works

**Check logs**:
```bash
docker compose logs -f
```

**Check dashboard**: [app.drosera.io/trap](https://app.drosera.io/trap)

**Check transactions**: [hoodi.ethpandaops.io](https://hoodi.ethpandaops.io/) - search your contract addresses (may be internal transactions)

### Submit to Discord

**Prepare**:
- GitHub URL
- Trap address
- Response address  
- Brief description
- Dashboard screenshots

**Submit**:
1. Join [Discord](https://discord.com/invite/drosera)
2. Create ticket for role submission
3. Submit info
4. Wait for review

---

## Troubleshooting

### Common Trap Requirements

**Contract Structure**:
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

contract MyUniqueTrap is ITrap {
    function collect() external view override returns (bytes memory) {
        // Gather data - keep cheap and focused
    }
    
    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        // Analyze data - MUST be pure (no state reads, no external calls)
        // MUST be deterministic (same input = same output)
        // Return: (trigger boolean, response payload)
    }
}
```

**Critical Rules**:
- collect(): `view`, returns `bytes memory`, keep cheap
- shouldRespond(): `pure`, deterministic, no external calls
- Avoid: `block.timestamp`, randomness, external state reads
- Response function signature MUST match shouldRespond() payload

**Common Errors**:
- "Function must be pure": Remove state reads from shouldRespond()
- "Payload mismatch": Verify `abi.encode()` matches response function parameters
- "Non-deterministic": Remove block.timestamp or random values

### Quick Fixes

**Compilation errors**:
```bash
forge build --force
cat src/MyUniqueTrap.sol
```
Paste full error to AI.

**Deployment failures**:
```bash
curl https://rpc.hoodi.ethpandaops.io/
cast balance YOUR_ADDRESS --rpc-url https://rpc.hoodi.ethpandaops.io
```
Paste error to AI.

**Drosera errors**: Paste `drosera dryrun` or `drosera apply` error to AI with context.

**Stuck debugging**: Your idea might be too complex - simplify conditions or data collection.

**GitHub errors**: Regenerate PAT with both `repo` and `workflow` scopes.

**Get help**: [#technical Discord](https://discord.com/invite/drosera)

---

## Additional Resources

**Video Guide**: [Reiji's walkthrough](https://x.com/Reiji4kt/status/1973679261547413736)

**Documentation**: [docs.drosera.io](https://docs.drosera.io) | [book.getfoundry.sh](https://book.getfoundry.sh/)

---

## Key Principles

1. Your trap must be unique
2. Use AI to generate contracts
3. Ask community for help
4. Document professionally

Good luck Trappers! 🧡🧡

---

**Created by**: riot' (@idle0x)  
**Version**: 1.0  
**Last Updated**: October 2025
