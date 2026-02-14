# Complete Technical Guide

**[← Back to Quick Start](README.md)**

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Phase 1: Local Development](#phase-1-local-development)
3. [Phase 2: Drosera Integration](#phase-2-drosera-integration)
4. [Phase 3: Operator Setup](#phase-3-operator-setup)
5. [Phase 4: GitHub Publication](#phase-4-github-publication)
6. [Phase 5: Dashboard Verification](#phase-5-dashboard-verification)
7. [Troubleshooting](#troubleshooting)
8. [Trap Quality Standards](#trap-quality-standards)
9. [Examples: Good vs Bad Traps](#examples-good-vs-bad-traps)

---

## Prerequisites

<details>

### Essential Requirements

- **Ubuntu VPS** with SSH access (or similar Linux environment)
- **Ethereum wallet** with private key
- **GitHub account**
- **Drosera operator running** (Cadet and Corporal roles completed)
- **Basic terminal familiarity**

**Verify operator status:**
```bash
systemctl status drosera-operator
```
Expected: `active (running)` in green

**Check Drosera installation:**
```bash
drosera --version
```

</details>

---

## Network Selection

<details>

**Hoodi Testnet:**
- For learning and testing trap logic
- Uses simulated data patterns
- Lower stakes environment
- RPC: `https://rpc.hoodi.ethpandaops.io/`
- Chain ID: `560048`
- Drosera Address: `0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D`

**Ethereum Mainnet:**
- For production monitoring
- Monitors real protocol data
- Requires high-quality trap design
- RPC: `https://eth.llamarpc.com`
- Chain ID: `1`
- Drosera Address: `0x0c4f7e9684a11805Fc5406989F5124bFC2AD0D84`

</details>

---

## Phase 1: Local Development

<details>
<summary>Step 1: Screen Session (Recommended)</summary>

Preserve your work if connection drops:

```bash
screen -S drosera
```

**To detach:** Press `Ctrl+A`, then `D`

**Reattach if disconnected:**
```bash
screen -r drosera
```

**To exit screen permanently:**
```bash
exit
```

</details>

---

<details>
<summary>Step 2: Project Setup</summary>

Replace `{folder-name}` with your trap's kebab-case name:

```bash
mkdir ~/{folder-name}
cd ~/{folder-name}
forge init
rm src/Counter.sol script/Counter.s.sol test/Counter.t.sol
```

**Verify you're in the right directory:**
```bash
pwd
```
Expected: `/home/your-username/{folder-name}`

</details>

---

<details>
<summary>Step 3: Install Dependencies & Interface</summary>

```bash
# Install Foundry (if needed)
curl -L https://foundry.paradigm.xyz | bash
source ~/.bashrc
foundryup

# Install libraries
forge install foundry-rs/forge-std@v1.8.2 --no-commit
forge install OpenZeppelin/openzeppelin-contracts@v5.0.2 --no-commit

# Create ITrap interface directory
mkdir -p lib/drosera-contracts/interfaces

# Create interface file
nano lib/drosera-contracts/interfaces/ITrap.sol
```

**Paste the Exact ITrap interface (CRITICAL):**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITrap {
    function collect() external view returns (bytes memory);
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory);
}
```

> **⚠️ CRITICAL:** Note that `shouldRespond` takes `bytes[]` (array), NOT `bytes` (singular). This is non-negotiable for Drosera compatibility.

**Save and exit nano:**
- Press `Ctrl+X`
- Press `Y` to confirm
- Press `Enter` to save

**Verify installation:**
```bash
ls lib/forge-std/src
ls lib/openzeppelin-contracts/contracts
cat lib/drosera-contracts/interfaces/ITrap.sol
```

</details>

---

<details>
<summary>Step 4: Create Contract Files</summary>

Create your trap contracts. 
- For AI-generated code, follow the [copilot prompt](https://github.com/Idle0x/Drosera-Unique-Trap/blob/main/README.md#-copy-the-complete-ai-copilot-prompt).
- For manual creation, use the guidelines below:

#### 1. Trap Contract (`src/{TrapName}Trap.sol`):

```bash
nano src/{YourTrapName}Trap.sol
```

**Must implement `ITrap` interface:**
- `collect()`: Gathers monitoring data from blockchain/contracts
- `shouldRespond()`: Evaluates if trigger conditions are met

**CRITICAL REQUIREMENTS:**
- `collect()` MUST be `view` (not `pure`)
- `shouldRespond()` MUST be `pure` (not `view`)
- `shouldRespond` MUST take `bytes[]` calldata (not `bytes`)
- `data[0]` contains the **newest** block data (Drosera ordering)
- **ALWAYS** check `if (data.length == 0 || data[0].length == 0)` before decoding
- Return `bytes("")` for empty returns (not `""`)
- **NO storage variables** - Trap is redeployed every block by Drosera
- Use `constant` or `immutable` for fixed values

**Save with:** `Ctrl+X`, `Y`, `Enter`

---

#### 2. Response Contract (`src/{TrapName}Response.sol`):

```bash
nano src/{YourTrapName}Response.sol
```

Contains the action to execute when trap triggers.

> **⚠️ CRITICAL AUTHORIZATION WARNING:**
> - **DO NOT** use `require(msg.sender == address(trap))`
> - The Trap contract does NOT call your Response function
> - The Drosera Operator/Executor calls it directly
> - Correct pattern: Use owner-based OR operator-based authorization

**Example of CORRECT authorization:**

```solidity
address public owner;
mapping(address => bool) public authorizedOperators;

constructor() {
    owner = msg.sender;
    authorizedOperators[msg.sender] = true;
}

modifier onlyOperator() {
    require(authorizedOperators[msg.sender], "Not authorized");
    _;
}

function setOperator(address operator, bool authorized) external {
    require(msg.sender == owner, "Not owner");
    authorizedOperators[operator] = authorized;
}

function handleAlert(bytes calldata payload) external onlyOperator {
    // Your response logic
}
```

**Example of WRONG authorization (will fail):**

```solidity
// ❌ BAD - Drosera executor calls Response, not the Trap
address public trapAddress;

modifier onlyTrap() {
    require(msg.sender == trapAddress, "Only trap");
    _;
}
```

**Save with:** `Ctrl+X`, `Y`, `Enter`

---

#### 3. Deploy Script (`script/Deploy.sol`):

```bash
nano script/Deploy.sol
```

**Deploy the Response Contract ONLY:**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/YourResponse.sol";

contract DeployScript is Script {
    function run() external {
        vm.startBroadcast();
        
        // Deploy ONLY the Response contract
        YourResponse response = new YourResponse();
        console.log("Response deployed at:", address(response));

        // STOP HERE - Do NOT deploy the Trap Contract
        // Drosera reads the Trap logic from compiled JSON artifact
        // Deploying it yourself creates address conflicts
        
        vm.stopBroadcast();
    }
}
```

**Why you don't deploy the Trap Contract:**
- Drosera operators run trap logic in their own execution environment
- They read the bytecode from your `out/` JSON artifact
- Deploying it yourself creates address conflicts and confusion

**Save with:** `Ctrl+X`, `Y`, `Enter`

</details>

---

<details>
<summary>Step 5: Configuration Files</summary>

**Create foundry.toml:**
```bash
nano foundry.toml
```

```toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
solc_version = "0.8.20"
optimizer = true
optimizer_runs = 200

[rpc_endpoints]
hoodi = "https://rpc.hoodi.ethpandaops.io/"
mainnet = "https://eth.llamarpc.com"
```

**Save with:** `Ctrl+X`, `Y`, `Enter`

---

**Create .env:**
```bash
nano .env
```

```env
PRIVATE_KEY=your_private_key_here
RPC_URL=https://rpc.hoodi.ethpandaops.io/
ETHERSCAN_API_KEY=optional_if_mainnet
```

**Save with:** `Ctrl+X`, `Y`, `Enter`

**Security:**
```bash
chmod 600 .env
echo ".env" >> .gitignore
```

</details>

---

<details>
<summary>Step 6: Compile & Test Locally</summary>

**Compile contracts:**
```bash
forge build
```

**Expected output:**
```
[⠊] Compiling...
[⠒] Compiling 3 files with 0.8.20
[⠢] Solc 0.8.20 finished in 2.15s
Compiler run successful!
```

**Verify compilation output:**
```bash
ls out/
```
Expected: Folders like `YourTrap.sol/`, `YourResponse.sol/`, etc.

**Test contracts (if tests exist):**
```bash
forge test -vv
```

**View specific output artifact:**
```bash
cat out/YourTrap.sol/YourTrap.json | head -n 50
```

</details>

---

<details>
<summary>Step 7: Deploy Response Contract</summary>

**For Hoodi Testnet:**
```bash
forge script script/Deploy.sol:DeployScript \
  --rpc-url hoodi \
  --private-key $PRIVATE_KEY \
  --broadcast -vvvv
```

**For Mainnet:**
```bash
forge script script/Deploy.sol:DeployScript \
  --rpc-url mainnet \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify -vvvv
```

**Save the Response contract address from output:**
```
Response deployed at: 0xYourResponseAddress...
```

**Important:** Only the Response contract is deployed. The Trap contract stays as compiled JSON.

</details>

---

## Phase 2: Drosera Integration

<details>
<summary>Step 1: Create drosera.toml</summary>

In your project root (`~/{folder-name}/`):

```bash
nano drosera.toml
```

**For Hoodi Testnet:**

```toml
[trap]
name = "{your-trap-name}"                    # e.g., "liquidity-drain-monitor"
url = "{github-username}/{repo-name}"        # e.g., "alice/uniswap-liquidity-trap"
chain_id = 560048
drosera_contract_address = "0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D"

[trap.contract]
path = "src/{YourTrapName}Trap.sol:{YourTrapName}Trap"

[trap.response]
address = "0xYourDeployedResponseAddress"
function_signature = "handleAlert(bytes)"    # MUST match your Response function
```

**For Mainnet:**

```toml
[trap]
name = "{your-trap-name}"
url = "{github-username}/{repo-name}"
chain_id = 1
drosera_contract_address = "0x0c4f7e9684a11805Fc5406989F5124bFC2AD0D84"

[trap.contract]
path = "src/{YourTrapName}Trap.sol:{YourTrapName}Trap"

[trap.response]
address = "0xYourDeployedResponseAddress"
function_signature = "handleAlert(bytes)"
```

**Key Points:**
- `name`: Must be kebab-case (lowercase with hyphens)
- `url`: Your GitHub `username/repository` (without https://)
- `path`: Format is `relative/path/to/file.sol:ContractName`
- `function_signature`: Must exactly match your Response contract's function name and parameters

**Save with:** `Ctrl+X`, `Y`, `Enter`

</details>

---

<details>
<summary>Step 2: Verify Response Function Matches</summary>

**Check your Response contract:**
```bash
cat src/{YourTrapName}Response.sol | grep "function"
```

**Example output:**
```solidity
function handleAlert(bytes calldata payload) external onlyOperator { ... }
```

**Ensure drosera.toml matches:**
```toml
function_signature = "handleAlert(bytes)"
```

**Common mistakes:**
- ❌ `function_signature = "handleAlert"` (missing parameters)
- ❌ `function_signature = "handleAlert(bytes memory)"` (use `bytes`, not `bytes memory`)
- ✅ `function_signature = "handleAlert(bytes)"` (correct)

**If using different parameter types:**
```solidity
function respond(uint256 value, address target) external { ... }
```
→ `function_signature = "respond(uint256,address)"`

</details>

---

<details>
<summary>Step 3: Test Configuration (Dry Run)</summary>

**Validate drosera.toml syntax:**
```bash
drosera trap test
```

**Expected output:**
```
✓ Configuration valid
✓ Trap contract found: src/YourTrap.sol:YourTrap
✓ Response address valid: 0x...
✓ Function signature valid: handleAlert(bytes)
✓ All checks passed
```

**Common errors and fixes:**

**Error: `trap contract not found`**
- Check `path` in drosera.toml
- Verify contract name matches exactly (case-sensitive)
- Ensure contract compiled: `forge build`

**Error: `response address invalid`**
- Verify address starts with `0x`
- Ensure address is checksummed
- Confirm deployment succeeded

**Error: `function signature invalid`**
- Check function exists in Response contract
- Verify parameter types match exactly
- Use canonical types: `uint256` not `uint`, `bytes` not `bytes memory`

</details>

---

<details>
<summary>Step 4: Deploy to Drosera Network</summary>

**Register trap with Drosera:**
```bash
drosera trap deploy
```

**This command:**
1. Reads `drosera.toml` configuration
2. Uploads Trap bytecode to Drosera network
3. Registers response contract address
4. Returns your Trap ID

**Expected output:**
```
🚀 Deploying trap to Drosera...
✓ Bytecode uploaded
✓ Response contract registered
✓ Trap deployed successfully

Trap ID: 0xYourTrapId...
Status: Pending operator authorization
```

**Save your Trap ID** - you'll need it for operator authorization.

**Verify deployment:**
```bash
drosera trap status --trap-id 0xYourTrapId
```

</details>

---

<details>
<summary>Step 5: Authorize Operator in Response Contract</summary>

**Why this is needed:**
- Your Response contract has authorization checks (e.g., `onlyOperator` modifier)
- Drosera operators need permission to call your Response function
- Without authorization, trap triggers will fail

**Get your operator address:**
```bash
drosera operator status
```

**Expected output:**
```
Operator Address: 0xYourOperatorAddress...
Status: Active
Role: Corporal
```

**Method 1: Using cast (recommended):**

```bash
cast send 0xYourResponseAddress \
  "setOperator(address,bool)" \
  0xYourOperatorAddress \
  true \
  --rpc-url hoodi \
  --private-key $PRIVATE_KEY
```

**Method 2: Using Foundry script:**

Create `script/AuthorizeOperator.sol`:
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/YourResponse.sol";

contract AuthorizeOperator is Script {
    function run() external {
        address responseAddress = 0xYourResponseAddress;
        address operatorAddress = 0xYourOperatorAddress;
        
        vm.startBroadcast();
        
        YourResponse response = YourResponse(responseAddress);
        response.setOperator(operatorAddress, true);
        
        console.log("Operator authorized:", operatorAddress);
        
        vm.stopBroadcast();
    }
}
```

Run:
```bash
forge script script/AuthorizeOperator.sol:AuthorizeOperator \
  --rpc-url hoodi \
  --private-key $PRIVATE_KEY \
  --broadcast
```

**Verify authorization:**
```bash
cast call 0xYourResponseAddress \
  "authorizedOperators(address)(bool)" \
  0xYourOperatorAddress \
  --rpc-url hoodi
```

Expected: `true`

</details>

---

## Phase 3: Operator Setup

<details>
<summary>Step 1: Configure Operator to Monitor Trap</summary>

**Add trap to operator config:**
```bash
drosera operator add-trap 0xYourTrapId
```

**Verify trap was added:**
```bash
drosera operator list-traps
```

Expected output:
```
Monitored Traps:
- 0xYourTrapId... (Status: Active)
```

</details>

---

<details>
<summary>Step 2: Start Operator Service</summary>

**If operator is already running:**
```bash
sudo systemctl restart drosera-operator
```

**If operator is not running:**
```bash
sudo systemctl start drosera-operator
```

**Check status:**
```bash
sudo systemctl status drosera-operator
```

Expected: `active (running)` in green

**View live logs:**
```bash
sudo journalctl -u drosera-operator -f
```

**Look for:**
```
INFO: Monitoring trap 0xYourTrapId...
INFO: Collect function called
INFO: shouldRespond returned: false
```

</details>

---

<details>
<summary>Step 3: Monitor Operator Logs</summary>

**Follow logs in real-time:**
```bash
sudo journalctl -u drosera-operator -f --lines=50
```

**Healthy log patterns:**
```
[INFO] Block 12345678: Executing collect()
[INFO] Block 12345678: shouldRespond() = false
[INFO] Block 12345679: Executing collect()
[INFO] Block 12345679: shouldRespond() = false
```

**Trap triggered pattern:**
```
[INFO] Block 12345680: Executing collect()
[WARN] Block 12345680: shouldRespond() = true
[INFO] Calling response function: handleAlert(bytes)
[INFO] Response executed successfully
[INFO] Trap cooldown: 100 blocks
```

**Error patterns to watch for:**

```
[ERROR] Failed to call collect(): <reason>
```
→ Issue with Trap contract's `collect()` function

```
[ERROR] Failed to decode collect() output
```
→ Check return type matches between Trap and operator

```
[ERROR] Response function reverted: Not authorized
```
→ Operator not authorized in Response contract (see Phase 2, Step 5)

```
[ERROR] Response function not found
```
→ `function_signature` mismatch in drosera.toml

**Filter logs by trap ID:**
```bash
sudo journalctl -u drosera-operator | grep "0xYourTrapId"
```

</details>

---

<details>
<summary>Step 4: Verify Trap is Active</summary>

**Check trap status:**
```bash
drosera trap status --trap-id 0xYourTrapId
```

**Expected output:**
```
Trap ID: 0xYourTrapId
Status: Active
Operator: 0xYourOperatorAddress
Last Collect: Block 12345680
Last Trigger: Never (or Block 12345650)
Cooldown: 100 blocks
Response Contract: 0xYourResponseAddress
```

**If status is not "Active":**

**Status: "Pending"**
→ Operator hasn't picked up trap yet. Wait 1-2 minutes or restart operator.

**Status: "Inactive"**
→ Operator stopped monitoring. Re-add trap: `drosera operator add-trap 0xYourTrapId`

**Status: "Error"**
→ Configuration issue. Check logs and verify drosera.toml

</details>

---

## Phase 4: GitHub Publication

<details>
<summary>Step 1: Initialize Git Repository</summary>

**In your project directory:**
```bash
cd ~/{folder-name}
git init
```

**Create .gitignore:**
```bash
nano .gitignore
```

```
# Foundry
out/
cache/
broadcast/

# Environment
.env
.env.local

# IDE
.vscode/
.idea/

# OS
.DS_Store
```

**Save with:** `Ctrl+X`, `Y`, `Enter`

</details>

---

<details>
<summary>Step 2: Create README.md</summary>

```bash
nano README.md
```

**Template:**
```markdown
# {Your Trap Name}

## Description
{Brief description of what vulnerability or condition your trap monitors}

## Trap Logic
- **Monitoring:** {What data sources/contracts are monitored}
- **Trigger Condition:** {When the trap triggers}
- **Response Action:** {What happens when triggered}

## Contracts
- **Trap:** `src/{YourTrapName}Trap.sol`
- **Response:** `src/{YourTrapName}Response.sol`
- **Response Deployed:** `0xYourResponseAddress` (Hoodi Testnet / Mainnet)

## Configuration
- **Chain:** Hoodi Testnet (or Ethereum Mainnet)
- **Trap ID:** `0xYourTrapId`
- **Cooldown:** 100 blocks

## Usage
This trap is monitored by Drosera operators. When trigger conditions are met, the Response contract's `handleAlert` function is called automatically.

## Testing
```bash
forge build
forge test
```

## Deployment
See [TECHNICAL-GUIDE.md](TECHNICAL-GUIDE.md) for full deployment instructions.
```

**Save with:** `Ctrl+X`, `Y`, `Enter`

</details>

---

<details>
<summary>Step 3: Commit and Push to GitHub</summary>

**Stage files:**
```bash
git add .
```

**Commit:**
```bash
git commit -m "Initial trap implementation"
```

**Create GitHub repository:**
1. Go to https://github.com/new
2. Repository name: `{your-trap-name}` (same as in drosera.toml)
3. Public or Private: **Public** (required for Drosera dashboard)
4. Do NOT initialize with README (you already have one)
5. Click "Create repository"

**Add remote and push:**
```bash
git remote add origin https://github.com/{username}/{repo-name}.git
git branch -M main
git push -u origin main
```

**Verify:**
Visit `https://github.com/{username}/{repo-name}` - you should see your code.

</details>

---

<details>
<summary>Step 4: Verify drosera.toml URL Matches</summary>

**Check your drosera.toml:**
```bash
cat drosera.toml | grep "url"
```

**Should show:**
```toml
url = "{username}/{repo-name}"
```

**If it doesn't match your GitHub repo:**
```bash
nano drosera.toml
```

Update the `url` field, save, then:
```bash
drosera trap deploy
```

(This updates the trap configuration)

</details>

---

## Phase 5: Dashboard Verification

<details>
<summary>Step 1: Access Drosera Dashboard</summary>

**Navigate to:**
- Hoodi: https://dashboard.drosera.io/hoodi
- Mainnet: https://dashboard.drosera.io/mainnet

**Connect wallet** (the one you used to deploy)

</details>

---

<details>
<summary>Step 2: Find Your Trap</summary>

**Search by:**
- Trap ID: `0xYourTrapId`
- Trap name: `{your-trap-name}`
- Your address

**Verify displayed information:**
- ✅ Trap name matches drosera.toml
- ✅ GitHub link works and shows your repo
- ✅ Status shows "Active"
- ✅ Response contract address correct
- ✅ Recent collect() calls visible

</details>

---

<details>
<summary>Step 3: Monitor Activity</summary>

**Dashboard shows:**
- **Last Collect:** When `collect()` was last called
- **Last Trigger:** When trap last returned `true`
- **Total Triggers:** Lifetime count
- **Operators:** How many operators are monitoring
- **Cooldown Status:** Blocks until next trigger allowed

**Healthy trap indicators:**
- Regular collect() calls (every block or every few blocks)
- Trigger count is low (0-5 for most traps)
- Operator count > 0
- No error messages

**Concerning patterns:**
- No recent collect() calls → Operator not running
- High trigger count (>20) → Trap too noisy, needs refinement
- Error messages → Check logs and fix issues

</details>

---

## Troubleshooting

<details>
<summary>Issue: Trap not appearing on dashboard</summary>

**Check:**
1. GitHub repository is public
2. `url` in drosera.toml matches GitHub `username/repo-name`
3. Trap deployed successfully: `drosera trap status --trap-id 0xYourTrapId`
4. Wait 5-10 minutes for dashboard to sync

**Solution:**
```bash
# Verify drosera.toml URL
cat drosera.toml | grep url

# Re-deploy if needed
drosera trap deploy
```

</details>

---

<details>
<summary>Issue: Operator logs show "collect() failed"</summary>

**Common causes:**
1. RPC endpoint issues
2. Contract call reverted
3. Incorrect contract address in configuration

**Check:**
```bash
# Test RPC connection
cast block latest --rpc-url hoodi

# Verify trap contract compiles
forge build

# Check operator logs for specific error
sudo journalctl -u drosera-operator -n 100 | grep ERROR
```

**Solution:**
- If RPC issue: Update RPC in operator config
- If contract issue: Review Trap's `collect()` function - ensure it's `view` and doesn't revert
- Ensure all external calls in `collect()` have proper error handling

</details>

---

<details>
<summary>Issue: shouldRespond() always returns false</summary>

**Diagnosis:**
```bash
# Check recent collect data
sudo journalctl -u drosera-operator | grep "collect() returned"
```

**Common causes:**
1. Thresholds too strict (never met in test environment)
2. Logic error in condition checking
3. Data decoding issues

**Solutions:**

**Test with relaxed thresholds:**
```solidity
// BEFORE (too strict for testing):
uint256 public constant THRESHOLD = 1000000;

// AFTER (relaxed for testing):
uint256 public constant THRESHOLD = 100;
```

**Add debug logging (for local testing):**
```solidity
function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
    if (data.length == 0 || data[0].length == 0) return (false, bytes(""));
    
    (uint256 value) = abi.decode(data[0], (uint256));
    
    // For testing, return data for inspection
    if (value > THRESHOLD) {
        return (true, abi.encode(value, THRESHOLD));
    }
    
    return (false, abi.encode(value, THRESHOLD)); // Include data even when false
}
```

**Verify data format:**
```bash
# Test collect() locally
forge test --match-test testCollect -vvvv
```

</details>

---

<details>
<summary>Issue: Response function not being called</summary>

**Check operator authorization:**
```bash
# Get operator address
drosera operator status

# Verify authorization in Response contract
cast call 0xYourResponseAddress \
  "authorizedOperators(address)(bool)" \
  0xYourOperatorAddress \
  --rpc-url hoodi
```

Expected: `true`

**If false:**
```bash
cast send 0xYourResponseAddress \
  "setOperator(address,bool)" \
  0xYourOperatorAddress \
  true \
  --rpc-url hoodi \
  --private-key $PRIVATE_KEY
```

**Check function signature match:**
```bash
# View your Response contract function
cat src/YourResponse.sol | grep "function.*public\|external"

# Compare with drosera.toml
cat drosera.toml | grep function_signature
```

**Common mismatches:**
- ❌ Contract: `handleAlert(bytes memory)` / Config: `handleAlert(bytes)`
  → **Fix:** Use `bytes calldata` in contract
- ❌ Contract: `respond()` / Config: `handleAlert(bytes)`
  → **Fix:** Update config to match contract function name

</details>

---

<details>
<summary>Issue: Compilation errors with ITrap interface</summary>

**Error: `ITrap not found`**

**Solution:**
```bash
# Verify interface file exists
cat lib/drosera-contracts/interfaces/ITrap.sol

# If missing, recreate:
mkdir -p lib/drosera-contracts/interfaces
nano lib/drosera-contracts/interfaces/ITrap.sol
```

Paste exact interface from Phase 1, Step 3.

**Error: `function signature mismatch`**

**Common mistake:**
```solidity
// ❌ WRONG
function shouldRespond(bytes calldata data) external pure returns (bool, bytes memory)

// ✅ CORRECT
function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory)
```

**Solution:** Ensure `bytes[]` (array) in both interface and implementation.

</details>

---

<details>
<summary>Issue: Trap triggers too frequently (noisy)</summary>

**Diagnosis:**
```bash
# Check trigger frequency
drosera trap status --trap-id 0xYourTrapId
```

If "Total Triggers" is high (>20) and trap has been running <1 day, it's too noisy.

**Common causes:**
1. Threshold too low
2. Monitoring normal activity instead of anomalies
3. No multi-condition logic (single vector)

**Solutions:**

**Increase thresholds:**
```solidity
// BEFORE:
uint256 public constant THRESHOLD = 50;

// AFTER:
uint256 public constant THRESHOLD = 100;
```

**Add multi-condition logic:**
```solidity
// BEFORE (single condition):
if (value > THRESHOLD) return (true, ...);

// AFTER (multi-condition):
bool condition1 = value > THRESHOLD_1;
bool condition2 = delta > THRESHOLD_2;
bool condition3 = ratio > THRESHOLD_3;

uint8 met = 0;
if (condition1) met++;
if (condition2) met++;
if (condition3) met++;

if (met >= 2) return (true, ...); // Requires 2/3 conditions
```

**Add time/block-based filtering:**
```solidity
// Only trigger if change happened quickly
uint256 blockDelta = newBlock - oldBlock;
if (blockDelta <= 10 && valueChange > THRESHOLD) {
    return (true, ...);
}
```

</details>

---

<details>
<summary>Issue: "Response address invalid" error</summary>

**Verify Response contract deployment:**
```bash
# Check if contract exists at address
cast code 0xYourResponseAddress --rpc-url hoodi
```

**If returns `0x`:** Contract not deployed at that address.

**Solution:**
```bash
# Re-deploy Response contract
forge script script/Deploy.sol:DeployScript \
  --rpc-url hoodi \
  --private-key $PRIVATE_KEY \
  --broadcast -vvvv
```

**Update drosera.toml with new address:**
```bash
nano drosera.toml
```

Update `address = "0xNewResponseAddress"`

**Re-deploy trap:**
```bash
drosera trap deploy
```

</details>

---

<details>
<summary>Issue: Git push authentication fails</summary>

**Error:**
```
remote: Support for password authentication was removed
```

**Solution: Use Personal Access Token**

1. Go to https://github.com/settings/tokens
2. Click "Generate new token" → "Generate new token (classic)"
3. Select scopes: `repo` (all), `workflow`
4. Click "Generate token"
5. **Copy token** (you won't see it again)

**Update remote URL:**
```bash
git remote set-url origin https://{username}:{token}@github.com/{username}/{repo-name}.git
```

**Or use SSH instead:**
1. Generate SSH key:
   ```bash
   ssh-keygen -t ed25519 -C "your_email@example.com"
   ```
2. Add to GitHub: Settings → SSH Keys → New SSH key
3. Update remote:
   ```bash
   git remote set-url origin git@github.com:{username}/{repo-name}.git
   ```

</details>

---

<details>
<summary>Issue: Operator not starting / systemctl fails</summary>

**Check operator service status:**
```bash
sudo systemctl status drosera-operator
```

**If "failed" or "inactive":**
```bash
# View detailed logs
sudo journalctl -u drosera-operator -n 100 --no-pager

# Check for common errors:
# - "config not found" → Operator config file missing
# - "invalid key" → Private key issue
# - "RPC connection failed" → Network/RPC issue
```

**Solution for config issues:**
```bash
# Verify operator config exists
cat ~/.drosera/operator-config.toml

# If missing, reinitialize operator
drosera operator init
```

**Solution for key issues:**
```bash
# Verify private key in config
cat ~/.drosera/operator-config.toml | grep private_key

# Update if needed
drosera operator set-key
```

**Restart operator:**
```bash
sudo systemctl restart drosera-operator
sudo systemctl status drosera-operator
```

</details>

---

<details>
<summary>Issue: Screen session lost / can't reattach</summary>

**List active screen sessions:**
```bash
screen -ls
```

**If shows "Attached" but you can't access:**
```bash
# Force detach
screen -D drosera

# Then reattach
screen -r drosera
```

**If no sessions found:**
Your session terminated. Restart your work:
```bash
screen -S drosera
cd ~/{folder-name}
```

**Prevent future loss:**
- Always detach properly: `Ctrl+A`, then `D`
- Don't close terminal without detaching
- Use tmux as alternative: `tmux new -s drosera`

</details>

---

## Trap Quality Standards

<details>
<summary>What Makes a High-Quality Trap</summary>

High-quality traps protect protocols by detecting real threats while avoiding false alarms. Here are the core principles:

### 1. Specificity
Monitor a **specific vulnerability** or anomaly, not generic activity.

**❌ Bad:** "Trigger when gas price is high"
**✅ Good:** "Trigger when Uniswap pool reserves drop >30% in <10 blocks"

### 2. Low Noise
Trigger only on **actual anomalies**, not normal usage patterns.

**Target trigger rate:** <5 triggers per month in normal conditions

### 3. Actionable Response
When triggered, the response should **mitigate or alert** about the threat.

**❌ Bad:** Response logs an event
**✅ Good:** Response pauses protocol, notifies multisig, or triggers emergency withdrawal

### 4. Multi-Vector Logic (Recommended)
Use **multiple conditions** that independently verify the threat.

**Example:** Monitor pool reserves AND price deviation AND transaction volume

**Benefit:**
- Catches attacks even if one data source is compromised
- Reduces false positives (requires multiple confirmations)
- More resilient to network delays

### 5. Proper Safety Checks
Always validate data before using it:

```solidity
if (data.length == 0 || data[0].length == 0) return (false, bytes(""));
```

### 6. No Storage Variables
Traps are redeployed every block, so storage doesn't persist:

```solidity
// ❌ BAD
uint256 public lastValue;

// ✅ GOOD
uint256 public constant BASELINE = 1000;
uint256 public immutable deployedAt;
```

</details>

---

<details>
<summary>Understanding Multi-Vector Traps</summary>

Multi-vector traps monitor **multiple independent signals** and trigger when conditions align.

### Why Multi-Vector?

**Single-vector traps** rely on one data point:
- Vulnerable to oracle failures
- Higher false positive rate
- Miss attacks that avoid that specific metric

**Multi-vector traps** cross-reference multiple sources:
- Resilient to single-point failures
- Lower false positive rate (requires agreement)
- Catch sophisticated attacks from multiple angles

### Flexible Threshold Pattern

For traps monitoring multiple conditions:
- **3-vector traps:** Trigger if ANY 2 or ALL 3 conditions met
- **4-vector traps:** Trigger if ANY 3 or ALL 4 conditions met
- **5-vector traps:** Trigger if ANY 3+ or ALL 5 conditions met

**Why this matters:**
- ✅ Catches threats even if one data source fails
- ✅ Reduces false negatives
- ✅ Still maintains low noise (requires multiple confirmations)
- ✅ More resilient to oracle issues or network delays

**Example: Good Flexible Threshold Logic**
```solidity
function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
    // 1. Safety Check
    if (data.length == 0 || data[0].length == 0) return (false, bytes(""));

    // 2. Decode data
    (uint256 val1, uint256 val2, uint256 val3) = abi.decode(data[0], (uint256, uint256, uint256));
    
    // 3. Check each condition independently
    bool condition1 = val1 > THRESHOLD_1;
    bool condition2 = val2 > THRESHOLD_2;
    bool condition3 = val3 > THRESHOLD_3;
    
    // 4. Count met conditions
    uint8 metConditions = 0;
    if (condition1) metConditions++;
    if (condition2) metConditions++;
    if (condition3) metConditions++;
    
    // 5. Trigger if ANY 2 of 3 conditions met
    if (metConditions >= 2) {
        return (true, abi.encode(val1, val2, val3, metConditions));
    }
    
    return (false, bytes(""));
}
```

</details>

---

<details>
<summary>What to Avoid</summary>

❌ **Always True Logic:**
```solidity
function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
    return (true, data[0]); // BAD: Triggers every block!
}
```

❌ **Generic Monitoring Without Context:**
```solidity
// BAD: Triggers frequently with no specific vulnerability targeted
if (block.basefee > 50 gwei) return (true, abi.encode(block.basefee));
```

❌ **Noisy Traps:**
- Triggers every few blocks
- No specific vulnerability being monitored
- Wastes operator resources

</details>

---

<details>
<summary>Best Practices</summary>

✅ **Use constants for thresholds:**
```solidity
uint256 public constant THRESHOLD = 1000;
```

✅ **Use immutable for constructor values:**
```solidity
address public immutable targetContract;
constructor(address _target) {
    targetContract = _target;
}
```

✅ **NO storage variables:**
```solidity
// ❌ BAD
uint256 public lastPrice;

// ✅ GOOD
uint256 public constant BASELINE_PRICE = 1000;
```

✅ **Always check data length:**
```solidity
if (data.length == 0 || data[0].length == 0) return (false, bytes(""));
```

✅ **Use bytes("") for empty returns:**
```solidity
return (false, bytes(""));  // ✅ Correct
return (false, "");          // ❌ Wrong
```

</details>

---

## Examples: Good vs Bad Traps

<details>
<summary>Bad Example: Always-Respond Trap</summary>

```solidity
contract BadTrap is ITrap {
    function collect() external view returns (bytes memory) {
        return abi.encode(block.number);
    }
    
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
        // BAD: Always returns true
        return (true, data[0]);
    }
}
```

**Problems:**
- Triggers every cooldown period (constant spam)
- Wastes gas
- Provides no monitoring value
- Adds noise to network

</details>

---

<details>
<summary>Bad Example: Generic Gas Monitor</summary>

```solidity
contract GenericGasTrap is ITrap {
    function collect() external view returns (bytes memory) {
        return abi.encode(block.basefee);
    }
    
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
        if (data.length == 0 || data[0].length == 0) return (false, bytes(""));
        
        (uint256 baseFee) = abi.decode(data[0], (uint256));
        
        // BAD: 20 gwei is exceeded frequently
        if (baseFee > 20 gwei) {
            return (true, abi.encode(baseFee));
        }
        
        return (false, bytes(""));
    }
}
```

**Problems:**
- No specific vulnerability targeted
- Triggers frequently during normal usage
- No context for why high gas matters
- Pure noise

</details>

---

<details>
<summary>Good Example: Multivector Liquidity Monitor</summary>

```solidity
contract LiquidityDrainTrap is ITrap {
    IUniswapV2Pair public immutable pair;
    uint256 public constant DRAIN_THRESHOLD = 30; // 30% drop
    uint256 public constant TIME_WINDOW = 10; // blocks
    uint256 public constant EXTREME_DRAIN = 50; // 50% drop
    
    constructor(address _pair) {
        pair = IUniswapV2Pair(_pair);
    }
    
    function collect() external view override returns (bytes memory) {
        (uint112 reserve0, uint112 reserve1, uint32 timestamp) = pair.getReserves();
        return abi.encode(reserve0, reserve1, block.number, timestamp);
    }
    
    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        // Safety check
        if (data.length < 2) return (false, bytes(""));
        
        (uint112 oldReserve0, , uint256 oldBlock, ) = abi.decode(data[1], (uint112, uint112, uint256, uint32));
        (uint112 newReserve0, , uint256 newBlock, ) = abi.decode(data[0], (uint112, uint112, uint256, uint32));
        
        // Check three conditions independently
        uint256 reserveDrop = ((oldReserve0 - newReserve0) * 100) / oldReserve0;
        uint256 blockDelta = newBlock - oldBlock;
        
        bool condition1_significantDrain = reserveDrop >= DRAIN_THRESHOLD;
        bool condition2_recentTime = blockDelta <= TIME_WINDOW;
        bool condition3_extremeDrain = reserveDrop >= EXTREME_DRAIN;
        
        // Count met conditions
        uint8 metConditions = 0;
        if (condition1_significantDrain) metConditions++;
        if (condition2_recentTime) metConditions++;
        if (condition3_extremeDrain) metConditions++;
        
        // Flexible threshold: Trigger if ANY 2 of 3 conditions met
        if (metConditions >= 2) {
            return (true, abi.encode(oldReserve0, newReserve0, blockDelta, metConditions));
        }
        
        return (false, bytes(""));
    }
}
```

**Why this is good:**
- Monitors specific vulnerability (liquidity drain attacks)
- Multiple independent conditions (multivector)
- Flexible triggering (ANY 2 of 3)
- Clear thresholds (30%, 50%, 10 blocks)
- Only triggers on actual anomalies
- Resilient to timing issues
- Proper safety checks

</details>

---

<details>
<summary>Good Example: Oracle Deviation Detector</summary>

```solidity
contract OracleDeviationTrap is ITrap {
    AggregatorV3Interface public immutable chainlinkFeed;
    IUniswapV2Pair public immutable uniswapPair;
    uint256 public constant DEVIATION_THRESHOLD = 5; // 5%
    
    constructor(address _feed, address _pair) {
        chainlinkFeed = AggregatorV3Interface(_feed);
        uniswapPair = IUniswapV2Pair(_pair);
    }
    
    function collect() external view override returns (bytes memory) {
        // Get Chainlink price
        (, int256 chainlinkPrice, , , ) = chainlinkFeed.latestRoundData();
        
        // Get Uniswap price
        (uint112 reserve0, uint112 reserve1, ) = uniswapPair.getReserves();
        uint256 uniswapPrice = (uint256(reserve1) * 1e18) / uint256(reserve0);
        
        return abi.encode(uint256(chainlinkPrice), uniswapPrice, block.timestamp);
    }
    
    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        // Safety check
        if (data.length == 0 || data[0].length == 0) return (false, bytes(""));

        (uint256 chainlinkPrice, uint256 uniswapPrice, uint256 timestamp) = abi.decode(
            data[0], 
            (uint256, uint256, uint256)
        );
        
        // Calculate deviation
        uint256 diff = chainlinkPrice > uniswapPrice 
            ? chainlinkPrice - uniswapPrice 
            : uniswapPrice - chainlinkPrice;
        uint256 deviationPercent = (diff * 100) / chainlinkPrice;
        
        if (deviationPercent >= DEVIATION_THRESHOLD) {
            return (true, abi.encode(chainlinkPrice, uniswapPrice, deviationPercent, timestamp));
        }
        
        return (false, bytes(""));
    }
}
```

**Why this is good:**
- Monitors critical infrastructure (oracles)
- Compares multiple data sources (multivector)
- Clear threshold (5% deviation)
- Detects real vulnerability (price manipulation, oracle failures)
- Silent by default
- Proper data validation

</details>

---

## Additional Resources

- **[Drosera Documentation](https://docs.drosera.io)** - Official network docs
- **[Foundry Book](https://book.getfoundry.sh)** - Smart contract development
- **[Solidity Documentation](https://docs.soliditylang.org)** - Language reference
- **[Discord Community](https://discord.gg/drosera)** - Get help and support

---

**[← Back to Quick Start](README.md)**
