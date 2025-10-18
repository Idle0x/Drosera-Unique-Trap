# Drosera Trap Creation Guide

Welcome! This guide helps you create and deploy a unique Drosera trap for blockchain anomaly detection.

---

## 🚀 Recommended: Interactive AI Assistant

The easiest way to complete this guide is with an AI assistant. It will generate trap ideas, handle all naming automatically, and walk you through each step one at a time.

### How to Start:

1. **Copy the entire prompt** from the box below
2. **Open your AI** (ChatGPT, Claude, Gemini, etc.)
3. **Paste and follow along** - the AI will guide you step-by-step

---

### 👇 Copy This Complete Prompt 👇

```
You are the "Drosera Trap Guide AI" - a friendly, patient expert assistant helping me create and deploy a unique Drosera trap.

REFERENCE GUIDE:
The complete technical reference is available at: https://github.com/Idle0x/Drosera-Unique-Trap
If you can access the URLsm, read this guide for complete context. If not, use the condensed instructions below and request specific sections from me when needed.

YOUR CORE MISSION:
Guide me through THREE distinct phases:
1. Get the trap working locally (forge build + deploy)
2. Make it live on Drosera Network
3. Publish to GitHub

CRITICAL INSTRUCTIONS:

PHASE 0 - IDEA GENERATION (START HERE):
- Welcome me warmly and explain you'll help create a unique trap
- Generate 3-5 creative trap ideas with SHORT descriptions (what it detects, why it matters)
- Keep it simple - I'm choosing an idea, not reviewing technical specs
- Wait for me to pick one before proceeding

NAMING SYSTEM (after I choose):
From my chosen idea (e.g., "Oracle Price Drift"), you will generate:
- PascalCase for contracts: OraclePriceDriftTrap, OraclePriceDriftResponse
- kebab-case for folders/GitHub: oracle-price-drift-trap  
- snake_case for config: oracle_price_drift_trap

Show me these names and get confirmation before proceeding.

PHASE 1 - LOCAL DEVELOPMENT:
Goal: Working contracts that compile and deploy

Steps you'll guide me through:
1. Project setup (mkdir, forge init, remove examples)
2. Install dependencies (forge-std, OpenZeppelin, ITrap interface)
3. Generate contracts with AI:
   - Have me get example contracts from reference repos
   - Give me a modified code-generation prompt with MY trap's naming
   - Prompt MUST specify Foundry Script format for Deploy.sol
   - Contracts must use my PascalCase names throughout
4. Create files (paste contracts into nano, save with Ctrl+X, Y, Enter)
5. Configuration files (foundry.toml, remappings.txt)
6. Compile: forge build
7. Create .env with private key
8. Deploy: forge script with proper command
9. Capture TRAP_ADDRESS and RESPONSE_ADDRESS from output

Rules:
- Give ONE or TWO commands at a time, then wait for "ok/done/next"
- Before forge build, warn: "If errors appear, paste the FULL message here"
- After deployment, explicitly ask: "What are your deployed addresses? Format: Trap: 0x... Response: 0x..."

PHASE 2 - DROSERA INTEGRATION:
Goal: Trap running on Drosera Network

Steps:
1. Request deployed addresses and wallet address from me
2. YOU generate complete drosera.toml with:
   - Correct path using my trap's PascalCase name
   - My deployed addresses
   - Correct response_function signature (you know this from the code you helped generate)
   - My wallet in whitelist
   - Proper snake_case trap key
3. Have me paste it into nano drosera.toml
4. Guide through: drosera dryrun
5. Guide through: drosera apply
6. Explain common errors (max traps reached, config mismatch)

PHASE 3 - GITHUB PUBLICATION:
Goal: Code published and ready for submission

Steps:
1. Generate README.md content based on my trap
2. Git initialization and commit
3. Create GitHub repo (explain steps)
4. Generate GitHub PAT (explain scopes needed)
5. Push to GitHub
6. Verify and cleanup
7. Prepare submission info (repo URL, addresses, description, screenshots)

ESSENTIAL BEHAVIORS:
- Never give more than 2 commands without waiting for my response
- Always use MY trap's specific names (never generic "MyUniqueTrap")
- Before error-prone steps, say: "Paste any errors here for help"
- After nano edits, remind: "Save with Ctrl+X, then Y, then Enter"
- Be encouraging and patient

TECHNICAL REQUIREMENTS FOR CODE GENERATION:
When you give me the code-generation prompt, ensure it specifies:
- collect() must be "view", can read blockchain state
- shouldRespond() must be "pure", deterministic, no external calls
- Response function signature must match shouldRespond() payload
- Deploy.sol must use Foundry Script format:

  import {Script} from "forge-std/Script.sol";
  contract Deploy is Script {
      function run() external {
          vm.startBroadcast();
          // deployments with console.log
          vm.stopBroadcast();
      }
  }

- Use Solidity ^0.8.20
- Include clear comments

If you need details beyond this summary, ask me to:
"Open the Technical Reference section in the guide (below the prompt box) and find the section on [specific topic], then paste it here."

READY? Start by welcoming me and presenting 3-5 unique trap ideas!
```

---

## 📖 Full Technical Reference

<details>
<summary><strong>Click to expand complete technical guide</strong> (for AI context and manual reference)</summary>

---

### Prerequisites

Before starting, ensure you have:
- Ubuntu VPS with SSH access (Termius or similar)
- GitHub account
- Ethereum wallet with private key (Hoodi testnet)
- ChatGPT or Claude AI access
- Cadet and Corporal roles in Drosera
- [Drosera operator running](https://github.com/izmerGhub/Drosera-Hoodi-Guide-Setup--Izmer?tab=readme-ov-file#2-drosera-operator-setup)

---

### Roles Overview

**Sergeant and Captain Requirements**:
- Create unique trap concept
- Deploy successfully
- Publish to GitHub
- Submit via Discord ticket
- Must have Cadet and Corporal roles first

---

## Part 1: Local Development

### Step 1: Project Setup

Replace `{folder-name}` with your trap's kebab-case name (e.g., `oracle-drift-trap`):

```bash
mkdir ~/{folder-name}
cd ~/{folder-name}
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

Paste this interface:
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITrap {
    function collect() external view returns (bytes memory);
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory);
}
```

Save: `Ctrl+X`, `Y`, `Enter`

Verify:
```bash
ls lib/forge-std/src lib/openzeppelin-contracts/contracts lib/drosera-contracts/interfaces/ITrap.sol
```

---

### Step 3: Generate Contracts

**Get Reference Examples** (2 minutes):
- Visit [this trap](https://github.com/Idle0x/block-time-anomaly-trap) or [Drosera examples](https://github.com/drosera-network/examples/tree/main/defi-automation)
- Copy any trap contract from `src/`
- Copy any response contract from `src/`

**Why**: These teach AI the correct import paths, structure, and patterns.

**AI Code Generation Prompt** (your AI assistant will provide this with YOUR trap's names filled in):

```
I need a UNIQUE Drosera trap for Hoodi testnet.

Generate THREE files with these EXACT names:
- {YourTrapName}Trap.sol
- {YourTrapName}Response.sol
- Deploy.sol

CRITICAL REQUIREMENTS:

For {YourTrapName}Trap.sol:
- Import: import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";
- Implement ITrap interface
- collect() function: view, returns bytes memory, CAN read state
- shouldRespond() function: pure, deterministic, NO state reads/external calls
- Use Solidity ^0.8.20
- Add helpful comments

For {YourTrapName}Response.sol:
- Response function MUST match shouldRespond() payload
- Include access control (onlyTrapConfig modifier)
- Emit events for tracking
- Constructor accepts trapConfig address
- Use Solidity ^0.8.20

For Deploy.sol:
- MUST use Foundry Script format:
  ```solidity
  import {Script} from "forge-std/Script.sol";
  import {Console} from "forge-std/console.sol";
  import {{YourTrapName}Trap} from "../src/{YourTrapName}Trap.sol";
  import {{YourTrapName}Response} from "../src/{YourTrapName}Response.sol";
  
  contract Deploy is Script {
      function run() external {
          vm.startBroadcast();
          
          {YourTrapName}Trap trap = new {YourTrapName}Trap(/* args if needed */);
          console.log("Trap deployed at:", address(trap));
          
          {YourTrapName}Response response = new {YourTrapName}Response(address(trap));
          console.log("Response deployed at:", address(response));
          
          vm.stopBroadcast();
      }
  }
  ```

EXAMPLE CONTRACTS (structure reference only):
[PASTE TRAP EXAMPLE]
[PASTE RESPONSE EXAMPLE]

Generate all three files ready to deploy.
```

---

### Step 4: Create Contract Files

Replace `{TrapName}` with your PascalCase trap name:

```bash
mkdir -p src
nano src/{TrapName}Trap.sol
```
Paste your AI-generated trap contract. Save: `Ctrl+X`, `Y`, `Enter`

```bash
nano src/{TrapName}Response.sol
```
Paste your AI-generated response contract. Save: `Ctrl+X`, `Y`, `Enter`

```bash
mkdir -p script
nano script/Deploy.sol
```
Paste your AI-generated deployment script. Save: `Ctrl+X`, `Y`, `Enter`

---

### Step 5: Configuration Files

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

---

### Step 6: Compile

```bash
forge build
```

Verify artifacts (replace `{TrapName}` with yours):
```bash
ls out/{TrapName}Trap.sol/{TrapName}Trap.json
ls out/{TrapName}Response.sol/{TrapName}Response.json
```

**If errors**: Copy full message and paste to AI.

---

### Step 7: Environment Setup

```bash
nano .env
```
```
PRIVATE_KEY=0xYOUR_PRIVATE_KEY_HERE
GITHUB_TOKEN=ADDED_IN_PART_3
```
Save and secure:
```bash
chmod 600 .env
```

---

### Step 8: Deploy

Ensure [operator is running](https://github.com/izmerGhub/Drosera-Hoodi-Guide-Setup--Izmer?tab=readme-ov-file#2-drosera-operator-setup).

```bash
source .env
export PRIVATE_KEY=$PRIVATE_KEY
forge script script/Deploy.sol --rpc-url https://rpc.hoodi.ethpandaops.io --private-key $PRIVATE_KEY --broadcast
```

**Capture output**:
```
Trap deployed at: 0xABCD...
Response deployed at: 0xEF12...
```

**If errors**: Paste to AI.

---

## Part 2: Drosera Integration

### Step 1: Create drosera.toml

Your AI will generate this with YOUR specific values. Replace all `{placeholders}`:

```bash
nano drosera.toml
```
```toml
ethereum_rpc = "https://rpc.hoodi.ethpandaops.io/"
drosera_rpc = "https://relay.hoodi.drosera.io"
eth_chain_id = 560048
drosera_address = "0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D"

[traps]
[traps.{your_trap_snake_case}]
path = "out/{YourTrapName}Trap.sol/{YourTrapName}Trap.json"
response_contract = "0xYOUR_RESPONSE_ADDRESS"
response_function = "{yourResponseFunction}(address,uint256)"
cooldown_period_blocks = 33
min_number_of_operators = 1
max_number_of_operators = 3
block_sample_size = 10
private = true
whitelist = ["0xYOUR_WALLET_ADDRESS"]
private_trap = true
address = "0xYOUR_TRAP_ADDRESS"
```

**Note**: AI knows your response function signature from the code it generated.

---

### Step 2: Test and Apply

```bash
drosera dryrun
```

If successful:
```bash
DROSERA_PRIVATE_KEY=your_private_key_here drosera apply --eth-rpc-url https://rpc.hoodi.ethpandaops.io
```

**Common Issues**:
- "Maximum traps reached": You have 2 traps (limit per wallet) - overwrite one or use new wallet
- Config errors: Paste to AI with your drosera.toml

---

## Part 3: GitHub Publication

### Step 1: Create Repository Files

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

**README.md** (AI will generate based on your trap):
```bash
nano README.md
```
```markdown
# {Your Trap Name}

## Overview
{What your trap detects and why it matters}

## Technical Details
- Monitors: {Your data points}
- Triggers: {Your conditions}
- Response: {Your action}

## Deployment
- Network: Hoodi Testnet (560048)
- Trap: {Your trap address}
- Response: {Your response address}

## License
{Your license - optional}
```

**LICENSE** (optional): Add from [choosealicense.com](https://choosealicense.com)

---

### Step 2: Initialize Git

```bash
git init
git add README.md LICENSE foundry.toml drosera.toml remappings.txt .gitignore src/ script/
git submodule update --init --recursive
git add lib/forge-std lib/openzeppelin-contracts lib/drosera-contracts
git status  # Verify .env NOT listed
git commit -m "Initial commit: {Your Trap Name}"
```

---

### Step 3: Create GitHub Repository

1. Go to [github.com/new](https://github.com/new)
2. Name: `{your-trap-kebab-case}`
3. Public visibility
4. Don't initialize with anything
5. Create repository
6. Copy URL: `https://github.com/YOUR_USERNAME/{your-trap-name}.git`

---

### Step 4: GitHub Token

1. Visit [github.com/settings/tokens](https://github.com/settings/tokens)
2. Generate new token (classic)
3. Name: `{your-trap}-token`
4. Scopes: `repo` AND `workflow`
5. Copy token: `ghp_...`

Add to .env:
```bash
nano .env
```
```
PRIVATE_KEY=0xYOUR_KEY
GITHUB_TOKEN=ghp_YOUR_TOKEN
```

---

### Step 5: Push

```bash
git remote add origin https://github.com/YOUR_USERNAME/{your-trap-name}.git
git remote -v
source .env
git push -u origin main
```

Enter username and paste token when prompted.

Verify at your GitHub URL.

---

### Step 6: Cleanup

```bash
rm .env
ls -la | grep .env  # Verify removed
```

---

### Step 7: Submit

**Check Functionality**:
```bash
docker compose logs -f  # Check operator logs
```
- Dashboard: [app.drosera.io/trap](https://app.drosera.io/trap)
- Explorer: [hoodi.ethpandaops.io](https://hoodi.ethpandaops.io)

**Submit to Discord**:
1. Join [Discord](https://discord.com/invite/drosera)
2. Create ticket for role submission
3. Provide:
   - GitHub URL
   - Trap address
   - Response address
   - Brief description
   - Dashboard screenshots
4. Wait for review

---

## Troubleshooting

### Contract Requirements

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

contract YourTrap is ITrap {
    function collect() external view override returns (bytes memory) {
        // CAN read state, balances, block.number, etc.
    }
    
    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        // MUST be pure - only analyze data parameter
        // NO state reads, NO external calls, NO block.timestamp
        // MUST be deterministic
    }
}
```

**Common Errors**:
- "Function must be pure": Remove state reads from shouldRespond()
- "Payload mismatch": Ensure abi.encode() matches response function parameters
- "Non-deterministic": Remove block.timestamp/randomness

### Quick Fixes

**Compilation**: Paste full error to AI

**Deployment**: 
```bash
curl https://rpc.hoodi.ethpandaops.io/  # Test RPC
cast balance YOUR_ADDRESS --rpc-url https://rpc.hoodi.ethpandaops.io  # Check funds
```

**Drosera**: Paste dryrun/apply error to AI with your drosera.toml

**GitHub**: Regenerate token with both `repo` and `workflow` scopes

**Get Help**: [#technical Discord](https://discord.com/invite/drosera)

---

## Resources

- **Video**: [Reiji's walkthrough](https://x.com/Reiji4kt/status/1973679261547413736)
- **Docs**: [docs.drosera.io](https://docs.drosera.io) | [Foundry](https://book.getfoundry.sh/)
- **Examples**: [My trap](https://github.com/Idle0x/block-time-anomaly-trap) | [Drosera examples](https://github.com/drosera-network/examples)

---

**Created by**: riot' (@idle0x)  
**Version**: 2.1  
**Last Updated**: October 2025

</details>

---

## Key Principles

1. Your trap must be **unique**
2. Use AI for step-by-step guidance
3. Focus on one phase at a time
4. Ask for help when stuck

Good luck! 🚀
