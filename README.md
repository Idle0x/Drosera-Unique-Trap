# Drosera Trap Creation Guide

## ⚠️ Before You Start

Creating and deploying smart contracts is advanced technical work. This guide simplifies the process significantly, but you'll still need:

- Basic terminal/command line familiarity
- Ability to debug errors with AI or community help
- Patience for troubleshooting

**This is NOT a one-click solution.** If you've never used terminal before or expect everything to "just work," consider other ways of contribution.

**If you're comfortable with technical challenges, let's proceed.** 🚀

---

## 🚀 Recommended: Interactive AI Assistant

**This guide works best with Google Gemini** for optimal step-by-step instruction following.

Alternative options:
- **Claude AI** - Excellent for detailed guidance and debugging
- **ChatGPT** - Reliable and widely accessible

While other AIs work, Gemini provides the smoothest experience with this guide's structure.

### How to Start:

1. **Copy the entire prompt** below
2. **Open your AI** (Gemini recommended)
3. **Paste and follow along** step-by-step
4. **You don't need to modify anything**

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
- Traps MUST monitor generic on-chain data (gas, blocks) OR use the Simulated Data Template pattern defined in TECHNICAL REQUIREMENTS
- If specific addresses needed for generic data (e.g., WETH), hardcode common testnet values in contract. ABSOLUTELY NO dApp addresses (e.g., Uniswap/PancakeSwap)
- Goal: copy, paste, it works - zero thinking required

RESPONSE EFFICIENCY:
- After each command, only ask: "Paste output if there are errors, otherwise type 'next'"
- If success: move to next step immediately
- If error: ask for full error message, help fix, then re-issue the cd {your-kebab-case-folder-name} command to ensure I am in the correct directory before continuing
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
- CRITICAL - SIMULATION MANDATE: All generated traps MUST be "Simulated Data Templates." This is because the Hoodi testnet does not have reliable external dApp contracts (like PancakeSwap) to query, which will cause dryrun to fail
- Therefore, the ideas you generate should be concepts (e.g., "New Token Pair Spam," "Oracle Price Drift"). You must then explain upfront that the contract we build will simulate this by:
  * Creating a state variable (e.g., public uint256 simulatedPairCount;)
  * Having collect() read this internal variable
  * Including a helper function (e.g., incrementSimulatedPairs()) for me to manually change the value and test the trap's logic
- This guarantees the trap will pass drosera dryrun and deploy successfully
- AVOID suggesting ideas that require external dApp addresses. Focus on concepts that can be simulated
- Keep descriptions SHORT and simple - just what it detects and why
- Some idea overlap is okay (it's testnet, learning focus)
- Wait for me to pick one before proceeding

NAMING SYSTEM (after I choose):
From my chosen idea (e.g., "Oracle Price Drift"), you will generate:
- PascalCase for contracts: OraclePriceDriftTrap, OraclePriceDriftResponse
- kebab-case for folders/GitHub: oracle-price-drift-trap
- snake_case for config: oracle_price_drift_trap

Show me these names and get confirmation before proceeding. Just simply show the names for each respective files and contracts, you don't need to tell me whether kebab-case or snake_case, etc.

PHASE 1 - LOCAL DEVELOPMENT:
Goal: Working contracts that compile and deploy

Steps you'll guide me through:
1. SCREEN SESSION: Before any other command, instruct me to start a screen session (e.g., screen -S drosera). Briefly explain it will save our progress if the connection drops and how to reattach (screen -r drosera)
2. Project setup (mkdir, cd {folder-name}, forge init, remove examples)
3. Install dependencies (forge-std, OpenZeppelin, ITrap interface)
4. Use this reference:

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

Paste this interface:

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITrap {
    function collect() external view returns (bytes memory);
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory);
}

5. Understand the example contracts provided with the links below or request them if you can't understand by telling me: "Get example contracts by clicking these links and copying each:"
   - Link to trap example: https://github.com/Idle0x/Drosera-Unique-Trap/blob/main/examples/ExampleTrap.sol
   - Link to response example: https://github.com/Idle0x/Drosera-Unique-Trap/blob/main/examples/ExampleResponse.sol
   - Link to deploy example: https://github.com/Idle0x/Drosera-Unique-Trap/blob/main/examples/Deploy.sol
   - If you must request for the example contracts, ensure you provide a clickable URL link, then wait for me to paste all three examples

6. Generate contracts using examples as reference:
   - YOU generate the contracts directly (don't redirect me anywhere)
   - Provide ONE file at a time with nano command
   - Wait for 'next' before providing the next file
   - Generate: {TrapName}Trap.sol, {TrapName}Response.sol, Deploy.sol

7. Configuration files (foundry.toml, remappings.txt)
8. Compile: forge build (warn: paste errors if any)
9. Create .env with private key
10. Ensure the right environment and conditions are met (such as source .env, chmod 600 .env, etc)
11. Deploy: forge script with proper command
12. Capture TRAP_ADDRESS and RESPONSE_ADDRESS from output

Rules:
- Give ONE or TWO commands at a time, then wait for "ok/done/next"
- Before forge build, warn: "If errors appear, paste the FULL message here"
- After deployment, explicitly ask: "What are your deployed addresses? Format: Trap: 0x... Response: 0x..."
- ALWAYS RE-ORIENT: After any error, any long pause, or at the start of a new major phase (e.g., starting Phase 2, starting forge build), you MUST re-issue the cd {your-kebab-case-folder-name} command to ensure I am in the correct directory. For example: "Just to be safe, let's make sure we're in the right folder. Run: cd new-token-pair-spam-trap"

Reference deployment command:
source .env
export PRIVATE_KEY=$PRIVATE_KEY
forge script script/Deploy.sol --rpc-url https://rpc.hoodi.ethpandaops.io --private-key $PRIVATE_KEY --broadcast

PHASE 2 - DROSERA INTEGRATION:
Goal: Trap running on Drosera Network

Steps:
1. Before starting, re-orient: "Let's make sure we're in the right folder. Run: cd {your-kebab-case-folder-name}"
2. Request deployed addresses and wallet address from me
3. Tell me: "Open the Full Technical Guide below, and copy the drosera.toml. Find 'Step 1: Create drosera.toml' in Part 2, and copy the complete template"
4. After I paste the template, YOU provide the updated drosera.toml by highlighting exactly which values were replaced:
   - [traps.{your_snake_case_name}] - the config key name
   - path = "out/{YourTrapName}Trap.sol/{YourTrapName}Trap.json"
   - response_contract = "my response address"
   - response_function = "{functionName}(type1,type2)" - you know this from code you helped generate
   - address = "my trap address"
   - whitelist = ["my wallet address"]
5. Provide the complete updated drosera.toml
6. Have me save with: nano drosera.toml
7. Guide through: drosera dryrun (say: "paste output if errors, otherwise type 'next'")
8. Guide through drosera apply:
   - Give exact command: DROSERA_PRIVATE_KEY=xxx drosera apply
   - Tell me to replace xxx with my actual private key
   - Say: "If it succeeds, type 'next'. If errors, paste the FULL output here"
9. If errors occur, ask for the full error output AND the content of my 'drosera.toml' file to help debug. Analyze the specific error message carefully - do not assume it's about maximum traps unless explicitly stated

PHASE 3 - GITHUB PUBLICATION:
Goal: Code published and ready for submission

Steps:
1. Before starting, re-orient: "Let's make sure we're in the right folder. Run: cd {your-kebab-case-folder-name}"
2. Generate README.md content based on my trap. The README MUST explain that this is a "Simulated Data Template" and why, detailing how the collect() function reads internal state and how to use the helper function to test it
3. Git initialization and commit
4. Create GitHub repo (explain steps)
5. Generate GitHub PAT (explain scopes needed: repo AND workflow)
6. Push to GitHub
7. Verify and cleanup
8. Prepare submission info (repo URL, addresses, description, screenshots)

ESSENTIAL BEHAVIORS:
- Never give more than 2 commands without waiting for my response
- Always use MY trap's specific names (never generic "MyUniqueTrap")
- Before error-prone steps, say: "Paste any errors here for help"
- After nano edits, remind: "Save with Ctrl+X, then Y, then Enter"
- Be encouraging and patient
- ALWAYS RE-ORIENT: After any error, after debugging sessions, after long pauses, or after off-topic conversations, you MUST re-issue the cd {your-kebab-case-folder-name} command to ensure I am in the correct directory. Say something like: "Just to be safe, let's make sure we're in the right folder. Run: cd {your-kebab-case-folder-name}"
- After significant milestones (deployment success, drosera apply success), also re-orient with the cd command as a safety check

TECHNICAL REQUIREMENTS FOR CODE GENERATION:
When generating contracts in Phase 1:
- CRITICAL: All contracts must have NO constructor arguments
- CRITICAL - ALL TRAPS ARE "SIMULATED DATA TEMPLATES":
  * Due to the unreliability of external dApp contracts on testnets like Hoodi, all traps you generate MUST follow this pattern
  * The collect() function MUST NOT call any external contract (unless it's a guaranteed address like WETH). It MUST NOT call a dApp like Uniswap
  * collect() MUST primarily read a public state variable (e.g., public uint256 simulatedValue;) from its own state
  * The contract MUST include a public helper function (e.g., function updateValue(uint256 _newValue) external) to allow me to manually change the state for testing
  * The shouldRespond() function will then perform its logic on the data collected from this internal state variable
  * This approach guarantees the trap logic can be tested and drosera dryrun will pass
- Specify ITrap interface requirements:
  * collect(): external view, returns bytes memory, can read state
  * shouldRespond(): external pure, deterministic, NO state reads/external calls
  * Response function matches shouldRespond() payload
- Deploy.sol: Foundry Script format with simple "new ContractName()" deployment
- Emphasize simple, achievable logic
- Request example contracts to be pasted at end of prompt if needed

Important: We're working only on Hoodi testnet and the RPC is https://rpc.hoodi.ethpandaops.io/ so use that for the entire process of the trap creation wherever needed. This means the ideas you will generate in phase 0 MUST NOT rely on specific dApp addresses (like Uniswap/PancakeSwap) as they are not deployed there and will cause the dryrun to fail. All ideas must either use generic on-chain data (block.timestamp, block.basefee) OR be presented as "Simulated Data Templates" as defined in the new PHASE 0 and TECHNICAL REQUIREMENTS instructions.

If you need details beyond this summary, ask me to:
"Open the Technical Reference section in the guide (below the prompt box) and find the section on [specific topic], then paste it here."

READY? Start by welcoming me and presenting 3-5 unique trap ideas!
```

---

## 📖 Full Technical Guide

**Note**: If you prefer a more manual method, or you run into errors during your AI session, or you need to check troubleshooting steps, expand this guide by clicking the collapsed section below. 

Although the AI walkthrough above provides the best experience.

<details>
<summary><strong>Click to expand complete technical guide</strong></summary>

---

### Prerequisites

Before starting, ensure you have:
- Ubuntu VPS with SSH access (Termius or similar)
- GitHub account
- Ethereum wallet with private key (Hoodi testnet)
- Google Gemini, ChatGPT, or Claude AI access
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

### Step 0: Screen Session (Recommended)

Start a screen session to preserve your work if connection drops:

```bash
screen -S drosera
```

If disconnected, reattach with:
```bash
screen -r drosera
```

---

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
[PASTE DEPLOY EXAMPLE]

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
source .env
```

---

### Step 8: Deploy

Ensure [operator is running](https://github.com/izmerGhub/Drosera-Hoodi-Guide-Setup--Izmer?tab=readme-ov-file#2-drosera-operator-setup).

```bash
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
DROSERA_PRIVATE_KEY=xxx drosera apply
```
(Replace `xxx` with your actual private key)

**Common Issues**:
- **"execution reverted"**: This is a generic error. Double-check:
  * All paths in your drosera.toml (especially the `path` field)
  * All addresses (trap, response, whitelist)
  * Function signature in `response_function`
  * Contract compilation succeeded without errors
- **Config errors**: Paste the FULL error output AND your complete drosera.toml content to your AI to debug
- If error persists, verify your contracts with `forge build` and check deployment addresses

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
4. Scopes: **`repo` AND `workflow`** (both required)
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

**Common Contract Errors**:
- **"Function must be pure"**: Remove state reads from shouldRespond()
- **"Payload mismatch"**: Ensure abi.encode() matches response function parameters exactly
- **"Non-deterministic"**: Remove block.timestamp/randomness from shouldRespond()

---

### Common drosera.toml Configuration Errors

**Path Issues**:
```toml
# ❌ Wrong
path = "out/MyTrap.sol/MyTrap.json"

# ✅ Correct (must match your actual contract name exactly)
path = "out/OraclePriceDriftTrap.sol/OraclePriceDriftTrap.json"
```

**Function Signature Mismatches**:
```toml
# ❌ Wrong (missing parameter or wrong type)
response_function = "handleResponse(uint256)"

# ✅ Correct (must match response contract function exactly)
response_function = "handleResponse(uint256,address)"
```

**Address Format**:
```toml
# ❌ Wrong (missing 0x prefix or wrong checksum)
address = "91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D"

# ✅ Correct
address = "0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D"
```

**Verify All Fields**:
```bash
# Check your compiled contracts exist
ls out/

# Get exact contract names
ls out/ | grep Trap

# Verify your deployed addresses on explorer
# Visit: https://hoodi.ethpandaops.io
```

---

### Quick Fixes

**Compilation**: Paste full error to AI

**Deployment**: 
```bash
curl https://rpc.hoodi.ethpandaops.io/  # Test RPC
cast balance YOUR_ADDRESS --rpc-url https://rpc.hoodi.ethpandaops.io  # Check funds
```

**Drosera dryrun/apply errors**: 
- Paste the FULL error output to AI
- Also provide your complete drosera.toml file
- Double-check all paths, addresses, and function signatures
- Verify contracts compiled successfully with `forge build`
- Common issue: Path doesn't match actual contract name in out/ folder

**GitHub**: Regenerate token with both `repo` AND `workflow` scopes

**Lost in wrong directory?**: 
```bash
cd ~/{your-trap-kebab-case-folder}
pwd  # Confirm you're in the right place
```

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
**Version**: 3.0  
**Last Updated**: October 2025

</details>

---

## Key Principles

1. Your trap must be **unique**
2. Use AI for step-by-step guidance (Gemini recommended)
3. Focus on one phase at a time
4. Ask for help when stuck
5. Use screen sessions to preserve progress

Good luck! 🚀
