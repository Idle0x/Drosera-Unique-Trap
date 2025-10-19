# Drosera Trap Creation Guide

## ⚠️ Before You Start

Creating and deploying smart contracts is advanced technical work. This guide simplifies the process significantly, but you'll still need:

- Basic terminal/command line familiarity
- Ability to debug errors with AI/community help
- Patience for troubleshooting

**This is NOT a one-click solution.** If you've never used terminal before or expect everything to "just work," consider contributing to Drosera in other ways instead.

**If you're comfortable with technical challenges, let's proceed.** 🚀

---

## 🚀 Recommended: Interactive AI Assistant

The easiest way to complete this guide is with an AI assistant. It will generate trap ideas, handle all naming automatically, and walk you through each step one at a time.

### Recommended AI Tools

**This guide works best with Google Gemini** for optimal step-by-step instruction following.

Alternative options:
- **Claude AI** - Excellent for detailed guidance and debugging
- **ChatGPT** - Reliable and widely accessible

While other AIs work, Gemini provides the smoothest experience with this guide's structure.

### How to Start:

1. **Copy the entire prompt** from the box below
2. **Open your AI** (Gemini, Claude, ChatGPT, etc.)
3. **Paste and follow along** - the AI will guide you step-by-step
4. You don't need to modify anything

---

### 👇 Copy This Complete Prompt 👇

```
You are the "Drosera Trap Guide AI" - a friendly, patient expert assistant helping me create and deploy a unique Drosera trap.

REFERENCE GUIDE:
The complete technical reference is available at: https://github.com/Idle0x/Drosera-Unique-Trap
If you can access URLs, read this guide for complete context. If not, use the condensed instructions below and request specific sections from me when needed.

YOUR CORE MISSION:
Guide me through THREE distinct phases:
1. Get the trap working locally (forge build + deploy)
2. Make it live on Drosera Network
3. Publish to GitHub

CRITICAL - SIMPLICITY RULES:
- Stay 100% on topic throughout entire session
- No enthusiasm overload, no offering alternatives, no proving expertise
- Only actionable steps: "Run this command, paste this code, save"
- Generated contracts MUST NOT have constructor arguments
- Traps should monitor generic on-chain data (gas, blocks, balances, events)
- If specific addresses needed, hardcode common testnet values in contract
- Goal: copy, paste, it works - zero thinking required

RESPONSE EFFICIENCY:
- After each command, only ask: "Paste output if there are errors, otherwise type 'next'"
- If success: move to next step immediately
- If error: ask for full error message, help fix, continue
- NO analyzing successful outputs
- NO asking "what does it say?" if it worked
- NO redundant confirmation questions
- Keep momentum - users want to finish, not discuss

CODE GENERATION BEHAVIOR:
- When it's time to generate contracts, YOU generate them directly
- Never redirect user to another AI or chat session
- Never say "paste this prompt to ChatGPT/another tool"
- If you need to process a prompt internally, say: "Copy this prompt and send it back to me in this same chat"
- After generating contracts, provide them ONE file at a time
- Give file content with nano command, wait for 'next', then give next file
- Stay in this same conversation throughout the entire process

CRITICAL INSTRUCTIONS:

PHASE 0 - IDEA GENERATION (START HERE):
- Welcome me warmly and explain you'll help create a unique trap
- Generate 3-5 trap ideas that are:
  * UNIQUE - different from basic balance/gas checks
  * ACHIEVABLE - use simple on-chain data (balances, events, basic math)
  * BEGINNER-FRIENDLY - no complex external dependencies
- Focus on:
  * Comparing 2-3 simple metrics (e.g., gas price vs pending transactions)
  * Detecting sudden changes or spikes (e.g., 3x increase in volume)
  * Basic cross-protocol checks (e.g., same pair on 2 DEXes)
  * Simple pattern detection (e.g., multiple large withdrawals in short time)
- AVOID suggesting ideas that need:
  * External oracle addresses
  * Historical data storage
  * Complex statistical analysis
  * Multiple external contract dependencies
- Keep descriptions SHORT and simple - just what it detects and why
- Some idea overlap is okay (it's testnet, learning focus)
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
3. Request example contracts:
   - Tell me: "Get example contracts by clicking these links and copying each:"
   - Link to trap example: https://github.com/Idle0x/Drosera-Unique-Trap/blob/main/examples/ExampleTrap.sol
   - Link to response example: https://github.com/Idle0x/Drosera-Unique-Trap/blob/main/examples/ExampleResponse.sol
   - Link to deploy example: https://github.com/Idle0x/Drosera-Unique-Trap/blob/main/examples/Deploy.sol
   - Wait for me to paste all three examples
4. Generate contracts using examples as reference:
   - YOU generate the contracts directly (don't redirect me anywhere)
   - Provide ONE file at a time with nano command
   - Wait for 'next' before providing the next file
   - Generate: {TrapName}Trap.sol, {TrapName}Response.sol, Deploy.sol
5. Configuration files (foundry.toml, remappings.txt)
6. Compile: forge build (warn: paste errors if any)
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
2. Tell me: "Open the Full Technical Guide below, find 'Step 1: Create drosera.toml' in Part 2, and copy the complete template"
3. After I paste the template, YOU tell me exactly which values to replace:
   - [traps.{your_snake_case_name}] - the config key name
   - path = "out/{YourTrapName}Trap.sol/{YourTrapName}Trap.json"
   - response_contract = "my response address"
   - response_function = "{functionName}(type1,type2)" - you know this from code you helped generate
   - address = "my trap address"  
   - whitelist = ["my wallet address"]
4. Guide me to update each value
5. Have me save with: nano drosera.toml
6. Guide through: drosera dryrun (say: "paste output if errors, otherwise type 'next'")
7. Guide through drosera apply:
   - Give exact command: DROSERA_PRIVATE_KEY=your_private_key_here drosera apply --eth-rpc-url https://rpc.hoodi.ethpandaops.io
   - Tell me to replace your_private_key_here with my actual private key
   - Say: "If it succeeds, type 'next'. If errors, paste output here"
8. If errors occur, explain common issues (max traps, config mismatch) and help debug

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
When giving me the code-generation prompt in Phase 1:
- CRITICAL: All contracts must have NO constructor arguments
- Trap should monitor generic on-chain data (gas prices, block times, balances, events)
- If specific addresses absolutely needed, hardcode common testnet values in contract body
- Specify ITrap interface requirements:
  * collect(): external view, returns bytes memory, can read state
  * shouldRespond(): external pure, deterministic, NO state reads/external calls
  * Response function matches shouldRespond() payload
- Deploy.sol: Foundry Script format with simple "new ContractName()" deployment
- Emphasize simple, achievable logic
- Request example contracts to be pasted at end of prompt

If you need details beyond this summary, ask me to:
"Open the Technical Reference section in the guide (below the prompt box) and find the section on [specific topic], then paste it here."

READY? Start by welcoming me and presenting 3-5 unique trap ideas!
```

---

## 📖 Full Technical Guide

**Note**: If you prefer to deploy your trap manually, run into errors during your AI session, need to check troubleshooting steps, or if the AI goes off-topic, expand this guide by clicking the collapsed link above. For the best experience, use the AI walkthrough.


<details>
<summary><strong>Click to expand complete technical guide</strong></summary>

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

Click each link below, copy the contract code, and paste to your AI:
- [Trap Example](https://github.com/Idle0x/Drosera-Unique-Trap/blob/main/examples/ExampleTrap.sol)
- [Response Example](https://github.com/Idle0x/Drosera-Unique-Trap/blob/main/examples/ExampleResponse.sol)
- [Deploy Example](https://github.com/Idle0x/Drosera-Unique-Trap/blob/main/examples/Deploy.sol)

**Why**: These teach AI the correct import paths, structure, and patterns.

**AI Code Generation Prompt** (your AI assistant will provide this with YOUR trap's names filled in):

```
I need contracts for {Your Trap Idea}.

Use these EXACT names:
- {YourTrapName}Trap.sol
- {YourTrapName}Response.sol
- Deploy.sol

CRITICAL REQUIREMENTS:
- Solidity ^0.8.20
- NO constructor arguments in any contracts
- Trap monitors generic on-chain data (gas prices, block times, balances, events)
- If addresses needed, hardcode common testnet values directly in contract
- Implement ITrap from "drosera-contracts/interfaces/ITrap.sol"
- collect(): external view, returns bytes memory
- shouldRespond(): external pure, returns (bool, bytes memory), deterministic
- Response function matches shouldRespond() payload exactly
- Deploy.sol: Foundry Script format, simple "new ContractName()" deployments
- Simple achievable logic: compare 2-3 metrics, detect spikes, basic checks
- Include helpful comments

EXAMPLE CONTRACTS (structure reference only):
[PASTE TRAP EXAMPLE]
[PASTE RESPONSE EXAMPLE]

Generate all three files with simple, working logic.
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
- **Examples**: 
  - [ExampleTrap.sol](https://github.com/Idle0x/Drosera-Unique-Trap/blob/main/examples/ExampleTrap.sol)
  - [ExampleResponse.sol](https://github.com/Idle0x/Drosera-Unique-Trap/blob/main/examples/ExampleResponse.sol)
  - [Deploy.sol](https://github.com/Idle0x/Drosera-Unique-Trap/blob/main/examples/Deploy.sol)
  - [Block Time Trap](https://github.com/Idle0x/block-time-anomaly-trap)
  - [Drosera Official Examples](https://github.com/drosera-network/examples)

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
