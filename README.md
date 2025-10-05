# Complete Guide: Creating and Deploying a Unique Drosera Trap

## Introduction

This guide provides a comprehensive, step-by-step approach to creating, deploying, and publishing a unique Drosera trap on an Ubuntu cloud VPS using Termius.

For reference, you can examine [my deployed trap](https://github.com/Idle0x/block-time-anomaly-trap) or pick an example at [Drosera Network Examples](https://github.com/drosera-network/examples/tree/main/defi-automation) to understand the structure and workflow. However, your implementation must be entirely unique.

---

## Recommended AI Tools

For optimal results throughout this guide, I recommend using:
- **ChatGPT** - Excellent for generating Solidity contracts and deployment scripts
- **Claude AI** - Particularly effective for detailed explanations and debugging assistance

These AI tools will help you generate contract code, deployment scripts, and troubleshoot errors throughout the development process.

---

## Sergeant and Captain Roles

This guide is designed to help you achieve both available roles in the Drosera ecosystem:

**Requirements:**
- Develop a unique trap concept
- Deploy the fully operational trap
- Publish code to GitHub
- Submit through official Discord ticket system
- Receive recognition from Drosera team
- You must have the Cadet and Corporal roles

---

## DISCLAIMER: Create Something UNIQUE

**This is NOT a copy-paste tutorial.** The purpose of this guide is to provide a framework for creating your own distinct trap, not to replicate existing implementations.

The placeholders in this guide are intentionally generic. You must replace them with logic specific to your trap's purpose.

---

## Prerequisites

Before beginning, ensure you have:
- Ubuntu VPS with terminal access (via Termius or similar SSH client)
- Active GitHub account
- Basic familiarity with terminal commands
- Ethereum wallet with private key (for Hoodi testnet)
- Access to ChatGPT or Claude AI (strongly recommended)
- Clear concept for your unique trap's anomaly detection logic
- Cadet and Corporal roles 
- Drosera operator running (setup from Cadet/Corporal process - if not, see [Izmer's Operator Setup Guide](https://github.com/izmerGhub/Drosera-Hoodi-Guide-Setup--Izmer?tab=readme-ov-file#2-drosera-operator-setup))

---

## Part 1: Creating Your Unique Trap

### Step 1: Set Up the Project Directory

**Purpose**: Creates a dedicated directory for your trap project and initializes it with Foundry.

1. **Create and Navigate to Directory**:
   ```bash
   mkdir ~/my-unique-trap
   cd ~/my-unique-trap
   ```
   **Explanation**: Replace `my-unique-trap` with a name that reflects your specific trap concept.

2. **Initialize Foundry Project**:
   ```bash
   forge init
   ```
   **Explanation**: Initializes a Foundry project, creating standard directories (`src/`, `script/`, `test/`, `lib/`) and configuration files.

3. **Remove Example Files**:
   ```bash
   rm ~/my-unique-trap/src/Counter.sol
   rm ~/my-unique-trap/script/Counter.s.sol
   rm ~/my-unique-trap/test/Counter.t.sol
   ```
   **Explanation**: Removes default Foundry example files.

---

### Step 2: Install Dependencies

**Purpose**: Installs necessary libraries and the Drosera interface.

1. **Install Foundry** (if not already installed):
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   source ~/.bashrc
   foundryup
   ```
   **Explanation**: Installs Foundry toolkit. Verify with `forge --version`.

2. **Install forge-std**:
   ```bash
   forge install foundry-rs/forge-std@v1.8.2
   ```
   **Explanation**: Adds Foundry's standard library stored in `lib/forge-std`.

3. **Install OpenZeppelin Contracts**:
   ```bash
   forge install OpenZeppelin/openzeppelin-contracts@v5.0.2
   ```
   **Explanation**: Adds OpenZeppelin library stored in `lib/openzeppelin-contracts`.

4. **Create Drosera Interface Directory**:
   ```bash
   mkdir -p ~/my-unique-trap/lib/drosera-contracts/interfaces
   ```

5. **Create ITrap.sol Interface**:
   ```bash
   nano ~/my-unique-trap/lib/drosera-contracts/interfaces/ITrap.sol
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
   
   **Explanation**: Defines the ITrap interface that all Drosera traps must implement.

6. **Verify Dependencies**:
   ```bash
   ls ~/my-unique-trap/lib/forge-std/src
   ls ~/my-unique-trap/lib/openzeppelin-contracts/contracts
   ls ~/my-unique-trap/lib/drosera-contracts/interfaces/ITrap.sol
   ```

---

### Step 3: Prepare Your Trap Logic with AI

**Purpose**: Before creating any files, you must work with an AI to design your trap's complete logic and generate the necessary contracts.

**IMPORTANT**: This step is critical. Do not proceed to Step 4 until you have completed this preparation and received your generated contracts from the AI.

#### What You Need to Define:

1. **Your Unique Trap Idea**
   - What specific anomaly or condition will your trap detect?
   - Why is this important to monitor?
   - How is it different from existing traps?
   - Figure this out with AI

2. **Data to Monitor** (can be one or multiple)
   - Clearly list all data your trap needs to collect
   - Figure this out with AI

3. **Trigger Conditions** (can be one or multiple)
   - Define exactly when your trap should trigger a response
   - Figure this out with AI

4. **Sophistication Level**
   - Simple: Single check, straightforward logic
   - Moderate: Multiple conditions, some calculation
   - Complex: Historical data analysis, statistical calculations, multiple interdependent conditions
   - Figure this out with AI

5. **Response Action**
   - What should happen when your trap triggers?
   - Examples: Emit event, pause protocol, send notification, execute protective action
   - Figure this out with AI

#### Preparation Process:

1. **Visit Example Traps**:
   - [My trap](https://github.com/Idle0x/block-time-anomaly-trap)
   - [Drosera examples](https://github.com/drosera-network/examples/tree/main/defi-automation)
   - Find an example similar to your concept
   - Copy the trap and response contract code as reference

2. **Work with AI** (ChatGPT or Claude):
   
   Use this example prompt structure:
   ```
   I want to create a Drosera trap that detects [YOUR UNIQUE IDEA - be specific].

   DATA TO MONITOR:
   - [List your data point(s) - can be one or multiple]
   - [Example: block timestamps, gas prices, token balances, etc.]

   TRIGGER CONDITIONS:
   - [List your condition(s) - can be one or multiple]
   - [Example: when block time < 2 seconds, or when price drops > 20%, etc.]

   SOPHISTICATION:
   - [Describe complexity: simple check, multiple conditions, historical analysis, etc.]

   RESPONSE ACTION:
   - [What should happen when triggered]

   Here's a reference trap contract I found:
   [PASTE EXAMPLE TRAP CONTRACT]

   Here's a reference response contract:
   [PASTE EXAMPLE RESPONSE CONTRACT]

   Generate:
   1. A custom trap contract implementing ITrap interface with:
      - collect() function that gathers my specific data
      - shouldRespond() function that checks my conditions and triggers appropriately
   2. A custom response contract that executes my desired response action
   3. Explanation of how they work together
   4. Any additional helper functions or logic needed

   Make sure the contracts are complete, compilable, and unique to my use case.
   ```

3. **Refine Through Multiple Rounds**:
   - Your first contracts or ideas may need adjustments
   - Test the logic, ask for clarifications
   - Request modifications if something doesn't match your needs
   - Iterate until you have complete, working contracts
   - Don't rush - this is the most important step

4. **Save Your Generated Contracts**:
   - Keep the trap contract code ready to paste
   - Keep the response contract code ready to paste
   - Keep the deployment script ready to paste
   - You'll paste these in Step 4

**You are now set to proceed to Step 4 once you have all contracts generated and ready.**

Please refer to the [troubleshooting section](https://github.com/Idle0x/Drosera-Unique-Trap/blob/main/README.md#troubleshooting) below if you need detailed explanations.

---

### Step 4: Create Project Files

**Purpose**: Creates the repository structure with your AI-generated contracts and configuration files.

#### 4.1 Create Source Contracts

1. **Create Trap Contract**:
   ```bash
   mkdir -p ~/my-unique-trap/src
   nano ~/my-unique-trap/src/MyUniqueTrap.sol
   ```
   **Paste your AI-generated trap contract here. See Step 3 preparation above.**
   
   Save and exit with `Ctrl+X`, `Y`, `Enter`.
   
   **Explanation**: This is your trap contract generated in Step 3. It must implement the ITrap interface with `collect()` and `shouldRespond()` functions tailored to your specific anomaly detection logic.

2. **Create Response Contract**:
   ```bash
   nano ~/my-unique-trap/src/MyUniqueResponse.sol
   ```
   **Paste your AI-generated response contract here. See Step 3 preparation above.**
   
   Save and exit with `Ctrl+X`, `Y`, `Enter`.
   
   **Explanation**: This contract handles actions when your trap triggers, generated by AI in Step 3 based on your trap's logic.

#### 4.2 Create Deployment Script

1. **Create Deploy.sol**:
   ```bash
   mkdir -p ~/my-unique-trap/script
   nano ~/my-unique-trap/script/Deploy.sol
   ```
   **Paste your AI-generated deployment script here. See Step 3 preparation above.**
   
   Save and exit with `Ctrl+X`, `Y`, `Enter`.
   
   **Explanation**: This Solidity script deploys both your trap and response contracts. Generated by AI in Step 3.

   **AI Prompt for Deployment Script** (if you didn't get it in Step 3):
   ```
   Create a Foundry deployment script that:
   1. Imports forge-std/Script.sol
   2. Deploys my trap contract: [YOUR TRAP CONTRACT NAME]
   3. Deploys my response contract: [YOUR RESPONSE CONTRACT NAME]
   4. Logs both deployed addresses
   ```

#### 4.3 Create Test File (OPTIONAL)

1. **Create Test Contract**:
   ```bash
   mkdir -p ~/my-unique-trap/test
   nano ~/my-unique-trap/test/MyUniqueTrap.t.sol
   ```
   Paste:
   ```solidity
   // SPDX-License-Identifier: MIT
   pragma solidity ^0.8.20;

   // Paste your AI-generated test contract here. See Step 3 preparation above.
   ```
   Save and exit with `Ctrl+X`, `Y`, `Enter`.
   
   **Explanation**: Tests are optional but recommended. Ask your AI to generate tests based on your trap's logic from Step 3.

#### 4.4 Create Configuration Files

1. **Create foundry.toml**:
   ```bash
   nano ~/my-unique-trap/foundry.toml
   ```
   Paste:
   ```toml
   [profile.default]
   src = "src"
   out = "out"
   libs = ["lib"]
   solc = "0.8.20"
   ```
   Save and exit with `Ctrl+X`, `Y`, `Enter`.

2. **Create remappings.txt**:
   ```bash
   nano ~/my-unique-trap/remappings.txt
   ```
   Paste:
   ```
   drosera-contracts/=lib/drosera-contracts/
   forge-std/=lib/forge-std/src/
   openzeppelin-contracts/=lib/openzeppelin-contracts/
   @openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/
   ds-test/=lib/openzeppelin-contracts/lib/forge-std/lib/ds-test/src/
   erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/
   halmos-cheatcodes/=lib/openzeppelin-contracts/lib/halmos-cheatcodes/src/
   ```
   Save and exit with `Ctrl+X`, `Y`, `Enter`.

3. **Create drosera.toml**:
   ```bash
   nano ~/my-unique-trap/drosera.toml
   ```
   Paste:
   ```toml
   ethereum_rpc = "https://rpc.hoodi.ethpandaops.io/"
   drosera_rpc = "https://relay.hoodi.drosera.io"
   eth_chain_id = 560048
   drosera_address = "0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D"

   [traps]
   [traps.my_unique_trap]
   path = "out/MyUniqueTrap.sol/MyUniqueTrap.json"
   response_contract = "UPDATE_WITH_RESPONSE_ADDRESS"
   response_function = "yourResponseFunction(string,uint256)"
   cooldown_period_blocks = 33
   min_number_of_operators = 1
   max_number_of_operators = 3
   block_sample_size = 10
   private = true
   whitelist = ["0xYOUR_WALLET_ADDRESS"]
   private_trap = true
   address = "UPDATE_WITH_TRAP_ADDRESS"
   ```
   Save and exit with `Ctrl+X`, `Y`, `Enter`.
   
   **Explanation**: Update `response_function` to match your actual response contract function signature. Update `response_contract` and `address` after deployment in Step 7. Update `whitelist` with your wallet address.

#### 4.5 Create Deployment Documentation (OPTIONAL)

1. **Create Deployment Directory**:
   ```bash
   mkdir -p ~/my-unique-trap/deployment
   ```

2. **Create DEPLOYMENT.md** (OPTIONAL):
   ```bash
   nano ~/my-unique-trap/deployment/DEPLOYMENT.md
   ```
   Paste:
   ```markdown
   # Deployment Log

   ## Hoodi Network (Chain ID: 560048)

   - **Trap Contract**: [Update after deployment]
   - **Response Contract**: [Update after deployment]
   - **Deployed At**: [Timestamp]

   ## Post-Deployment Steps
   1. Update drosera.toml with addresses
   2. Run: drosera dryrun
   3. Run: drosera apply
   ```
   Save and exit with `Ctrl+X`, `Y`, `Enter`.

3. **Create addresses.json** (OPTIONAL):
   ```bash
   nano ~/my-unique-trap/deployment/addresses.json
   ```
   Paste:
   ```json
   {
     "chainId": 560048,
     "network": "Hoodi Testnet",
     "trap": "UPDATE_AFTER_DEPLOYMENT",
     "response": "UPDATE_AFTER_DEPLOYMENT"
   }
   ```
   Save and exit with `Ctrl+X`, `Y`, `Enter`.

4. **Create TRANSACTIONS.md** (OPTIONAL):
   ```bash
   nano ~/my-unique-trap/deployment/TRANSACTIONS.md
   ```
   Paste:
   ```markdown
   # Transaction History

   ## Deployment
   - Trap: [TX_HASH]
   - Response: [TX_HASH]

   ## Verification
   - Trap: https://hoodi.ethpandaops.io/address/[ADDRESS]
   - Response: https://hoodi.ethpandaops.io/address/[ADDRESS]
   ```
   Save and exit with `Ctrl+X`, `Y`, `Enter`.

#### 4.6 Create Repository Files

1. **Create .gitignore**:
   ```bash
   nano ~/my-unique-trap/.gitignore
   ```
   Paste:
   ```
   # Foundry
   out/
   cache/
   broadcast/

   # Environment
   .env

   # IDE
   .vscode/
   .idea/

   # OS
   .DS_Store
   ```
   Save and exit with `Ctrl+X`, `Y`, `Enter`.

2. **Create LICENSE** (OPTIONAL):
   ```bash
   nano ~/my-unique-trap/LICENSE
   ```
   Paste your chosen license (e.g., MIT License with your name and year).
   Visit [Choose a License](https://choosealicense.com) for guidance.
   
   Save and exit with `Ctrl+X`, `Y`, `Enter`.

3. **Create README.md**:
   ```bash
   nano ~/my-unique-trap/README.md
   ```
   Paste:
   ```markdown
   # [Your Trap Name]

   ## Overview
   [Describe what anomaly your trap detects and why it matters]

   ## Technical Details
   - Monitors: [Your data points]
   - Triggers when: [Your conditions]
   - Response: [Your action]

   ## Deployment
   - Network: Hoodi Testnet (Chain ID: 560048)
   - Trap: [Address after deployment]
   - Response: [Address after deployment]

   ## License
   [Your license]
   ```
   Save and exit with `Ctrl+X`, `Y`, `Enter`.
   
   **Explanation**: Create a comprehensive README describing your trap. You can ask AI to generate this based on your trap's logic from Step 3.

---

### Step 5: Compile the Project

**Purpose**: Validates that your contracts compile without errors.

1. **Compile Contracts**:
   ```bash
   cd ~/my-unique-trap
   forge build
   ```
   **Explanation**: Compiles all contracts in `src/`. Errors will be displayed if compilation fails.

2. **Verify Compilation Artifacts**:
   ```bash
   ls ~/my-unique-trap/out/MyUniqueTrap.sol/MyUniqueTrap.json
   ls ~/my-unique-trap/out/MyUniqueResponse.sol/MyUniqueResponse.json
   ```
   **Explanation**: Confirms JSON artifacts were generated successfully.

**If compilation fails**: Copy the complete error message and paste it into ChatGPT or Claude for a specific fix. Or post in [#technical on Discord](https://discord.com/invite/drosera).

---

### Step 6: Set Up Environment Variables

**Purpose**: Securely stores sensitive credentials for deployment.

1. **Create .env File**:
   ```bash
   nano ~/my-unique-trap/.env
   ```
   Paste:
   ```
   PRIVATE_KEY=0xYOUR_PRIVATE_KEY_HERE
   GITHUB_TOKEN=WILL_BE_ADDED_IN_PART_2
   ```
   Save and exit with `Ctrl+X`, `Y`, `Enter`.
   
   **Explanation**: Replace with your actual Ethereum private key for Hoodi testnet.
   
   **Security Warning**: Never commit this file to Git.

2. **Secure the .env File**:
   ```bash
   chmod 600 ~/my-unique-trap/.env
   ```

---

### Step 7: Deploy Contracts

**Purpose**: Deploys your trap and response contracts to Hoodi testnet. Before deploying your drosera operator has most likely been set already, so proceed to the next step. However if not, [checkout Izmer's guide](https://github.com/izmerGhub/Drosera-Hoodi-Guide-Setup--Izmer?tab=readme-ov-file#2-drosera-operator-setup)

1. **Load and Export Environment Variables**:
   ```bash
   source ~/my-unique-trap/.env
   export PRIVATE_KEY=$PRIVATE_KEY
   ```

2. **Deploy with Forge Script**:
   ```bash
   forge script script/Deploy.sol --rpc-url https://rpc.hoodi.ethpandaops.io --private-key $PRIVATE_KEY --broadcast
   ```
   **Explanation**: Deploys both trap and response contracts using Foundry. Monitor output for deployed addresses.

3. **Note Your Deployed Addresses**:
   Expected output format (your addresses will differ):
   ```
   Trap deployed at: 0x1234567890abcdef1234567890abcdef12345678
   Response deployed at: 0xabcdef1234567890abcdef1234567890abcdef12
   ```

4. **Verify Deployment**:
   ```bash
   cat ~/my-unique-trap/broadcast/Deploy.sol/560048/run-latest.json
   ```

5. **Update drosera.toml**:
   ```bash
   nano ~/my-unique-trap/drosera.toml
   ```
   Update:
   - `response_contract = "0xYOUR_ACTUAL_RESPONSE_ADDRESS"`
   - `address = "0xYOUR_ACTUAL_TRAP_ADDRESS"`
   - `whitelist = ["0xYOUR_WALLET_ADDRESS"]`
   
   Save and exit with `Ctrl+X`, `Y`, `Enter`.
   
   **Note**: You'll deploy both contracts. You can overwrite your existing trap from Cadet/Corporal setup or create a new one using these addresses. The new response contract address is unique to your trap.

6. **Update Deployment Documentation** (if created):
   Update `deployment/DEPLOYMENT.md` and `deployment/addresses.json` with actual addresses.

**If deployment fails**: Copy the error and paste into AI or ask in [#technical on Discord](https://discord.com/invite/drosera).

---

### Step 8: Test and Apply Your Trap

**Purpose**: Tests your trap configuration and makes it live on the Drosera Network.

**Prerequisites**: 
- Successful `forge build` compilation (Step 5)
- Updated `drosera.toml` with response contract address (Step 7)

1. **Test Configuration with Dry Run**:
   ```bash
   drosera dryrun
   ```
   **Explanation**: Tests your trap configuration changes before making them live. This validates your setup without actually applying it to the network.

2. **Apply and Make Trap Live**:
   ```bash
   DROSERA_PRIVATE_KEY=your_eth_private_key_here drosera apply --eth-rpc-url https://rpc.hoodi.ethpandaops.io
   ```
   **Explanation**: Pushes your trap configuration to the Drosera Network and makes it live. Use the same private key you've been using throughout.

**Important Notes**:
- Errors can occur in either `drosera dryrun` or `drosera apply` even after successful compilation and updating `drosera.toml`
- If you encounter errors, copy the complete error message and paste it into ChatGPT or Claude for debugging
- If you've been debugging for a while without progress, your trap idea may be too complex and might need simplification
- If you receive a "maximum number of traps reached" error, you've hit the limit of 2 traps per wallet. You can either overwrite an existing trap or use a fresh wallet.

**If errors occur**: Copy the error and paste into AI, or ask in [#technical on Discord](https://discord.com/invite/drosera).

---

### Step 9: Test Your Trap (OPTIONAL)

**Purpose**: Verifies your trap works correctly.

1. **Run Unit Tests** (if created):
   ```bash
   forge test -vv
   ```

2. **Test On-Chain** (if applicable):
   ```bash
   cast call 0xYOUR_TRAP_ADDRESS "collect()(bytes)" --rpc-url https://rpc.hoodi.ethpandaops.io
   ```

3. **Check Events**:
   ```bash
   cast logs --rpc-url https://rpc.hoodi.ethpandaops.io 0xYOUR_RESPONSE_ADDRESS
   ```

---

## Part 2: Publishing to GitHub

### Step 1: Initialize Git Repository

```bash
cd ~/my-unique-trap
git init
```

---

### Step 2: Stage Files for Commit

```bash
# Stage core files
git add README.md LICENSE foundry.toml drosera.toml remappings.txt .gitignore
git add src/ script/ test/ deployment/

# Stage submodules
git submodule update --init --recursive
git add lib/forge-std lib/openzeppelin-contracts lib/drosera-contracts
```

**Verify**:
```bash
git status
```
Ensure `.env` and `broadcast/` are NOT listed.

---

### Step 3: Create Initial Commit

```bash
git commit -m "Initial commit: [Your Trap Name] - Unique Drosera trap implementation"
```

---

### Step 4: Create GitHub Repository

1. Go to: [GitHub New Repository](https://github.com/new)
2. **Repository name**: `my-unique-trap` (or your preferred name)
3. **Description**: Brief description of your trap
4. **Visibility**: Public
5. **Do NOT initialize** with README, .gitignore, or license
6. Click "Create repository"
7. Copy the URL: `https://github.com/YOUR_USERNAME/my-unique-trap.git`

---

### Step 5: Generate GitHub Personal Access Token

1. Go to: [GitHub Tokens](https://github.com/settings/tokens)
2. Click "Generate new token (classic)"
3. Configure:
   - **Note**: `my-unique-trap-token`
   - **Expiration**: 30 days or no expiration
   - **Scopes**: `repo`
4. Generate and copy token: `ghp_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX`

5. **Add to .env**:
   ```bash
   nano ~/my-unique-trap/.env
   ```
   Update:
   ```
   PRIVATE_KEY=0xYOUR_PRIVATE_KEY_HERE
   GITHUB_TOKEN=ghp_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   ```
   Save and exit with `Ctrl+X`, `Y`, `Enter`.

---

### Step 6: Push to GitHub

```bash
# Add remote
git remote add origin https://github.com/YOUR_USERNAME/my-unique-trap.git

# Verify
git remote -v

# Load token
source ~/my-unique-trap/.env

# Push
git push -u origin main
```

When prompted:
- **Username**: Your GitHub username
- **Password**: Paste your GitHub PAT

**Verify**: Visit `https://github.com/YOUR_USERNAME/my-unique-trap` and confirm all files are present.

---

### Step 7: Security Cleanup

```bash
# Remove local .env
rm ~/my-unique-trap/.env

# Verify removal
ls -la ~/my-unique-trap/ | grep .env
```

---

## Part 3: SUBMISSION

### Step 1: Verify Trap Functionality

#### 1.1 Monitor Activity

**Check Docker Logs**:
```bash
docker compose logs -f
```

**Monitor Dashboard**:
- Visit: [Drosera Dashboard](https://app.drosera.io/trap)
- Check your trap's status and activity

**Explanation**: Your operator logs will show trap collection activity. The dashboard provides visual monitoring of your trap's performance.

#### 1.2 Check Transactions

- Visit: [Hoodi Explorer](https://hoodi.ethpandaops.io/)
- Search for your trap and response contract addresses
- Confirm transactions are occurring (these may be internal transactions)

---

### Step 2: Submit to Drosera Discord

**Prepare Submission Information**:
- GitHub repository URL: `https://github.com/YOUR_USERNAME/my-unique-trap`
- Trap contract address: `0xYOUR_TRAP_ADDRESS`
- Response contract address: `0xYOUR_RESPONSE_ADDRESS`
- Brief description of your trap's unique purpose
- Transaction evidence (hashes or explorer links)
- **Screenshots from dashboard showing your trap activity**

**Submit**:
1. Join: [Drosera Discord](https://discord.com/invite/drosera)
2. Create ticket for role submission
3. Submit all prepared information
4. Wait for review

---

## Troubleshooting

### Common Trap Development Errors

Many errors occur due to not following Drosera trap requirements. Verify your trap adheres to these principles:

#### Required Contract Structure
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

contract YourTrap is ITrap {
    // Your implementation
}
```

#### Critical Requirements:

1. **ITrap Interface Implementation**
   - Must implement both `collect()` and `shouldRespond()` functions
   - These are required for your contract to qualify as a Drosera trap

2. **collect() Function Rules**
   - Must be `view` (can read state but not modify)
   - Must return `bytes memory`
   - Keep it cheap and focused - avoid expensive operations
   - Can call event data on Hoodi testnet
   - Example: `function collect() external view override returns (bytes memory)`

3. **shouldRespond() Function Rules**
   - **MUST be `pure`** - cannot read or modify state
   - **MUST be deterministic** - same input always produces same output
   - Must return `(bool, bytes memory)` - trigger boolean + response payload
   - No external calls allowed
   - Avoid non-deterministic operations:
     - ❌ `block.timestamp`
     - ❌ `block.number` (unless part of your specific logic)
     - ❌ Randomness functions
     - ❌ External state reads
     - ❌ `address(this).balance`
   - Example: `function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory)`

4. **Response Contract Rules**
   - Avoid constructor arguments (only use if absolutely necessary)
   - Keep contracts stateless when possible
   - Response function signature MUST match the payload from shouldRespond()

5. **Response Payload Matching**
   - The `bytes` returned from `shouldRespond()` must match your response contract's function signature
   - Example: If shouldRespond returns `abi.encode("alert", 100)`, response function must accept `(string, uint256)`

**Common Error**: "Function must be pure"
- **Cause**: shouldRespond() is reading state or making external calls
- **Fix**: Ensure shouldRespond() only analyzes the data parameter, no state access

**Common Error**: "Response payload mismatch"
- **Cause**: Bytes encoded in shouldRespond() don't match response function parameters
- **Fix**: Verify `abi.encode()` parameters match response function signature exactly

**Common Error**: "Non-deterministic behavior detected"
- **Cause**: Using block.timestamp, random values, or external calls in shouldRespond()
- **Fix**: Remove all non-deterministic operations from shouldRespond()

### Compilation Errors

```bash
forge build --force
cat ~/my-unique-trap/src/MyUniqueTrap.sol
```

**Best Fix**: Copy the complete error and paste into ChatGPT/Claude: "I'm getting this Solidity error: [PASTE ERROR]"

**Community Help**: Post in [#technical on Discord](https://discord.com/invite/drosera) with your error.

---

### Deployment Failures

```bash
# Check RPC
curl https://rpc.hoodi.ethpandaops.io/

# Check balance
cast balance YOUR_WALLET_ADDRESS --rpc-url https://rpc.hoodi.ethpandaops.io

# Review logs
cat ~/my-unique-trap/broadcast/Deploy.sol/560048/run-latest.json
```

**Best Fix**: Paste deployment error into AI.

**Community Help**: Share error in [#technical on Discord](https://discord.com/invite/drosera).

---

### Drosera Dryrun and Apply Errors

Even after successful compilation and updating `drosera.toml`, you may encounter errors when running:
- `drosera dryrun` 
- `drosera apply`

**Common Issues**:
- Configuration mismatch in `drosera.toml`
- Response function signature doesn't match contract
- Maximum traps limit reached (2 per wallet)
- Network connectivity issues

**Best Fix**: Copy the complete error message and paste into ChatGPT or Claude with context: "I'm getting this error from drosera dryrun/apply after successful forge build: [PASTE ERROR]"

**If Stuck**: If you've been debugging for a while without progress or can't find a solution, your trap idea may be too complex and might need to be simplified. Consider:
- Reducing the number of conditions
- Simplifying data collection logic
- Breaking complex logic into smaller steps

**Community Help**: Post in [#technical on Discord](https://discord.com/invite/drosera) with your error and `drosera.toml` configuration.

---

### Git/GitHub Issues

**Authentication failed**:
- Regenerate PAT: [GitHub Tokens](https://github.com/settings/tokens)
- Ensure `repo` scope is selected

**Repository not empty**:
```bash
git pull origin main --allow-unrelated-histories
git push origin main
```

**Best Fix**: Paste Git error into AI.

---

## Additional Resources

### Video Guide

For a detailed video walkthrough of the entire process, check out [Reiji's comprehensive guide](https://x.com/Reiji4kt/status/1973679261547413736).
---

## Final Notes

**Key Principles**:
1. Uniqueness is essential - your trap must be different
2. Use AI to generate custom code based on your specific idea
3. The community is available to help in Discord
4. Test thoroughly with dryrun before applying
5. Document your work professionally for submission

Good luck with your trap development!

---

**Created by**: riot' (@idle0x)  
**Version**: 1.0  
**Last Updated**: October 2025
