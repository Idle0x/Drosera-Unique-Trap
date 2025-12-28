# Complete Technical Guide

**[← Back to Quick Start](README.md)**

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Phase 1: Local Development](#phase-1-local-development)
3. [Phase 2: Drosera Integration](#phase-2-drosera-integration)
4. [Phase 3: GitHub Publication](#phase-3-github-publication)
5. [Phase 4: Dashboard Verification](#phase-4-dashboard-verification)
6. [Troubleshooting](#troubleshooting)
7. [Trap Quality Standards](#trap-quality-standards)
8. [Examples: Good vs Bad Traps](#examples-good-vs-bad-traps)

---

## Prerequisites

### Essential Requirements

- **Ubuntu VPS** with SSH access (or similar Linux environment)
- **Ethereum wallet** with private key
- **GitHub account**
- **Drosera operator running** (Cadet and Corporal roles completed)
- **Basic terminal familiarity**

### Network Selection

**Hoodi Testnet:**
- For learning and testing trap logic
- Uses simulated data patterns
- Lower stakes environment
- RPC: `https://rpc.hoodi.ethpandaops.io/`
- Chain ID: `560048`

**Ethereum Mainnet:**
- For production monitoring
- Monitors real protocol data
- Requires high-quality trap design
- RPC: `https://eth.llamarpc.com`
- Chain ID: `1`

---

## Phase 1: Local Development

### Step 1: Screen Session (Recommended)

Preserve your work if connection drops:

```bash
screen -S drosera
```

Reattach if disconnected:
```bash
screen -r drosera
```

### Step 2: Project Setup

Replace `{folder-name}` with your trap's kebab-case name:

```bash
mkdir ~/{folder-name}
cd ~/{folder-name}
forge init
rm src/Counter.sol script/Counter.s.sol test/Counter.t.sol
```

### Step 3: Install Dependencies & Interface

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

**Paste the Exact ITrap interface (CRITICAL):**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITrap {
    function collect() external view returns (bytes memory);
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory);
}
```

**⚠️ CRITICAL:** Note that `shouldRespond` takes `bytes[]` (array), NOT `bytes` (singular). This is non-negotiable for Drosera compatibility.

Save: `Ctrl+X`, `Y`, `Enter`

Verify installation:
```bash
ls lib/forge-std/src
ls lib/openzeppelin-contracts/contracts
ls lib/drosera-contracts/interfaces/ITrap.sol
```

### Step 4: Create Contract Files

Create your trap contracts. 
- For AI-generated code, follow the [copilot prompt](https://github.com/Idle0x/Drosera-Unique-Trap/blob/main/README.md#-copy-the-complete-ai-copilot-prompt).
- For manual creation:

#### 1. Trap Contract (`src/{TrapName}Trap.sol`):

- Must implement `ITrap` interface
- `collect()`: Gathers monitoring data
- `shouldRespond()`: Evaluates trigger conditions

**CRITICAL REQUIREMENTS:**
- `shouldRespond` MUST use signature: `function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory)`
- `data[0]` contains the **newest** block data (Drosera ordering)
- Always check `if (data.length == 0 || data[0].length == 0)` before decoding
- Return `bytes("")` for empty returns (not `""`)

#### 2. Response Contract (`src/{TrapName}Response.sol`):

Contains the action to execute when trap triggers.

**⚠️ CRITICAL AUTHORIZATION WARNING:**
- **DO NOT** use `require(msg.sender == address(trap))`
- The Trap contract does NOT call your Response function
- The Drosera Operator network calls it
- For testing: allow any caller OR restrict to your wallet address
- For production: use an owner-based access control

Example of **CORRECT** authorization:

```solidity
address public owner;

constructor() {
    owner = msg.sender;
}

modifier onlyOwner() {
    require(msg.sender == owner, "Only owner");
    _;
}

function handleAlert(uint256 value) external onlyOwner {
    // Your response logic
}
```

Example of **WRONG** authorization (will fail):

```solidity
// ❌ BAD - This will revert when Drosera calls it
address public trapAddress;

modifier onlyTrap() {
    require(msg.sender == trapAddress, "Only trap");
    _;
}
```

#### 3. Deploy Script (`script/Deploy.sol`):

To deploy the Response Contract ONLY

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/YourResponse.sol";

contract DeployScript is Script {
    function run() external {
        vm.startBroadcast();
        
        // 1. Deploy ONLY the Response contract
        YourResponse response = new YourResponse();
        console.log("Response deployed at:", address(response));

        // 2. STOP HERE - Do NOT deploy the Trap Contract
        // Drosera reads the Trap logic from your compiled JSON artifact
        // Attempting to deploy the Trap will cause issues
        
        vm.stopBroadcast();
    }
}
```

**Why you don't deploy the Trap Contract?:**
- Drosera operators run trap logic in their own execution environment
- They read the bytecode from your `out/` JSON artifact
- Deploying it yourself creates address conflicts

### Step 5: Configuration Files

**foundry.toml:**
```toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
solc = "0.8.20"
```

**remappings.txt:**
```
drosera-contracts/=lib/drosera-contracts/
forge-std/=lib/forge-std/src/
openzeppelin-contracts/=lib/openzeppelin-contracts/
@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/
ds-test/=lib/openzeppelin-contracts/lib/forge-std/lib/ds-test/src/
erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/
halmos-cheatcodes/=lib/openzeppelin-contracts/lib/halmos-cheatcodes/src/
```

### Step 6: Compile

```bash
forge build
```

Verify artifacts:
```bash
ls out/{TrapName}Trap.sol/{TrapName}Trap.json
ls out/{TrapName}Response.sol/{TrapName}Response.json
```

### Step 7: Environment Setup

```bash
nano .env
```

Add your private key:
```
PRIVATE_KEY=0xYOUR_PRIVATE_KEY_HERE
```

Secure and load:
```bash
chmod 600 .env
source .env
```

### Step 8: Deploy Response Contract

**For Hoodi Testnet:**
```bash
export PRIVATE_KEY=$PRIVATE_KEY
forge script script/Deploy.sol \
  --rpc-url https://rpc.hoodi.ethpandaops.io \
  --private-key $PRIVATE_KEY \
  --broadcast
```

**For Ethereum Mainnet:**
```bash
export PRIVATE_KEY=$PRIVATE_KEY
forge script script/Deploy.sol \
  --rpc-url https://eth.llamarpc.com \
  --private-key $PRIVATE_KEY \
  --broadcast
```

**Save your Response contract address from the output!**

---

## Phase 2: Drosera Integration

### Step 1: Create drosera.toml

**For Hoodi Testnet:**

```toml
ethereum_rpc = "https://rpc.hoodi.ethpandaops.io/"
drosera_rpc = "https://relay.hoodi.drosera.io"
eth_chain_id = 560048
drosera_address = "0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D"

[traps]
[traps.your_trap_snake_case]
path = "out/YourTrap.sol/YourTrap.json"
response_contract = "0xYOUR_RESPONSE_ADDRESS"
response_function = "yourFunction(address,uint256)"
cooldown_period_blocks = 20
min_number_of_operators = 1
max_number_of_operators = 2
block_sample_size = 1
private = true
whitelist = ["0xYOUR_WALLET_ADDRESS"]
private_trap = true

# DO NOT add 'address = ...' - Drosera auto-deploys the Trap
```

**For Ethereum Mainnet:**

```toml
ethereum_rpc = "https://eth.llamarpc.com"
drosera_rpc = "https://relay.mainnet.drosera.io"
eth_chain_id = 1
drosera_address = "0x0c4f7e9684a11805Fc5406989F5124bFC2AD0D84"

[traps]
[traps.your_trap_snake_case]
path = "out/YourTrap.sol/YourTrap.json"
response_contract = "0xYOUR_RESPONSE_ADDRESS"
response_function = "yourFunction(address,uint256)"
cooldown_period_blocks = 100
min_number_of_operators = 2
max_number_of_operators = 5
block_sample_size = 5
private = true
whitelist = ["0xYOUR_WALLET_ADDRESS"]
private_trap = true

# DO NOT add 'address = ...' - Drosera auto-deploys the Trap
```

**Key Fields:**

- `response_contract`: Your deployed Response contract address
- `response_function`: Must match your Response contract's function signature exactly
- `whitelist`: Your wallet address that can trigger the trap
- `block_sample_size`: Number of historical blocks to pass to `shouldRespond()` (1 for simple traps, 5+ for trend analysis)

**CRITICAL:** Do NOT include an `address` field - Drosera will auto-fill this when you run `drosera apply`

### Step 2: Test Configuration

```bash
drosera dryrun
```

This validates your trap logic without deploying. If successful, proceed to apply.

### Step 3: Deploy to Drosera Network

```bash
DROSERA_PRIVATE_KEY=your_actual_private_key drosera apply
```

**What happens:**
1. Drosera reads your compiled Trap contract from the `path` field
2. Drosera deploys the Trap contract automatically
3. Drosera registers the trap on the network
4. Drosera updates your `drosera.toml` with the Trap address

**Success indicators:**
- No error messages
- `drosera.toml` now contains `address = "0x..."`
- Trap appears in your operator dashboard

---

## Phase 3: GitHub Publication

### Step 1: Create README.md

Your README should include:

**For Mainnet Traps:**
- What vulnerability/condition it monitors
- Why this monitoring is valuable
- How it's designed to be efficient (quiet by default)
- Technical specifications
- How to verify it's working

**For Testnet Traps:**
- Explain it's a learning/testing trap
- What monitoring concept it demonstrates
- How the simulated data pattern works
- How to test the trigger logic

### Step 2: Git Initialization

Create `.gitignore`:
```
.env
out/
cache/
broadcast/
lib/
```

Initialize and commit:
```bash
git init
git add .
git commit -m "Initial commit: [Trap Name]"
```

### Step 3: Create GitHub Repository

1. Create a new **public** repository on GitHub
2. Name it using kebab-case: `your-trap-name`
3. Do not initialize with README (we have one)

### Step 4: Generate GitHub Token

Create a Personal Access Token with:
- `repo` scope
- `workflow` scope

Add to `.env`:
```
GITHUB_TOKEN=your_github_token
```

### Step 5: Push to GitHub

```bash
git remote add origin https://YOUR_USERNAME:YOUR_TOKEN@github.com/YOUR_USERNAME/repo-name.git
git branch -M main
git push -u origin main
```

### Step 6: Verify Publication

- Visit your repository URL
- Confirm README displays correctly
- Verify all contracts are visible

---

## Phase 4: Dashboard Verification

### Final Confirmation Steps

1. **Access your Drosera operator dashboard**
2. **Locate your trap** in the trap list
3. **Verify green blocks** - confirms successful monitoring
4. **Take screenshot** showing trap name and status
5. **Submit to Discord** for role verification

**Success Criteria:**
- ✅ Trap listed in dashboard
- ✅ Receiving green blocks (not errors)
- ✅ Published to GitHub
- ✅ README professionally documented

---

## Troubleshooting

### Common Issues and Solutions

#### 1. "Execution Reverted" Error During `drosera apply`

**Cause:** You manually deployed the Trap contract and included its address in `drosera.toml`.

**Solution:**
- Remove the `address = "0x..."` line from your `[traps.your_trap]` section
- Let Drosera deploy the Trap automatically
- Only the `response_contract` field should contain an address you deployed

#### 2. `drosera dryrun` Succeeds but `apply` Fails

**Possible causes:**
- Incorrect `response_function` signature
- Response contract not deployed to the correct network
- Missing `whitelist` entry
- Wallet not funded for deployment gas

**Debug steps:**
1. Verify Response contract on block explorer
2. Double-check function signature matches Response contract
3. Confirm wallet address in whitelist is correct
4. Check wallet has sufficient funds

#### 3. Compilation Errors (`forge build` fails)

**Common causes:**
- Missing dependencies (re-run `forge install` commands)
- Incorrect import paths (check `remappings.txt`)
- Solidity version mismatch (ensure `^0.8.20`)
- Wrong `shouldRespond` signature (must be `bytes[]`, not `bytes`)

**Solution:**
- Read full error message carefully
- Verify all dependencies installed: `ls lib/`
- Check import statements match remappings
- Verify ITrap interface matches exactly
- Use AI assistant for debugging specific errors

#### 4. Trap Not Appearing in Dashboard

**Check:**
- Operator is running: `systemctl status drosera-operator`
- Correct network selected in dashboard
- `drosera apply` completed successfully
- Wait a few minutes for network propagation

#### 5. Red Blocks in Dashboard (Errors)

**Causes:**
- `collect()` function reverts (external call fails)
- `shouldRespond()` function has bugs
- Missing safety check: `if (data.length == 0)` before decoding
- Network connectivity issues

**Solution:**
- Review trap logic for potential revert conditions
- Add defensive checks in `shouldRespond()`
- Test with `drosera dryrun` on current network state
- Check operator logs for specific error messages

---

## Trap Quality Standards

### What Makes a Good Trap?

#### Silent Watchdog Pattern
- **Returns false most of the time** - Only triggers on critical events
- **Efficient gas usage** - Operators can run sustainably
- **Clear trigger conditions** - Well-defined thresholds
- **Flexible thresholds (3+ vectors)** - Adapts to partial attack patterns

#### Flexible Threshold Logic (NEW)
For traps with 3+ conditions, implement flexible triggering:
- **3-vector traps:** Trigger if ANY 2 or ALL 3 conditions met
- **4-vector traps:** Trigger if ANY 3 or ALL 4 conditions met
- **5-vector traps:** Trigger if ANY 3+ or ALL 5 conditions met

**Why this matters:**
- ✅ Catches threats even if one data source fails
- ✅ Reduces false negatives
- ✅ Still maintains low noise (requires multiple confirmations)
- ✅ More resilient to oracle issues or network delays

#### Example: Good Mainnet Trap (with Flexible Threshold)
```solidity
function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
    // 1. Safety Check: Ensure data exists
    if (data.length == 0 || data[0].length == 0) return (false, bytes(""));

    // 2. Decode NEWEST data (Index 0)
    (uint256 oraclePrice, uint256 dexPrice, uint256 volume) = abi.decode(
        data[0], 
        (uint256, uint256, uint256)
    );
    
    // 3. Check each condition independently
    uint256 deviation = abs(oraclePrice - dexPrice) * 100 / oraclePrice;
    bool condition1_priceDeviation = deviation > 5; // >5% deviation
    bool condition2_unusualVolume = volume > 1000000 * 10**18; // >1M tokens
    bool condition3_extremeDeviation = deviation > 10; // >10% extreme case
    
    // 4. Count met conditions
    uint8 metConditions = 0;
    if (condition1_priceDeviation) metConditions++;
    if (condition2_unusualVolume) metConditions++;
    if (condition3_extremeDeviation) metConditions++;
    
    // 5. Trigger if ANY 2 of 3 conditions met (flexible threshold)
    if (metConditions >= 2) {
        return (true, abi.encode(oraclePrice, dexPrice, volume, metConditions));
    }
    
    // 6. Default Return
    return (false, bytes(""));
}
```

**Why this is good:**
- Monitors multiple conditions (multivector)
- Has meaningful thresholds
- Uses flexible triggering (ANY 2 of 3)
- Returns false unless threshold reached
- Detects potential price manipulation even if volume data fails
- Includes safety check for empty data
- Uses `bytes("")` for empty returns

#### What to Avoid

❌ **Always True Logic:**
```solidity
function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
    return (true, data[0]); // BAD: Triggers every block!
}
```

❌ **Generic Monitoring:**
```solidity
// BAD: Just checks if gas > threshold
if (block.basefee > 50 gwei) return (true, abi.encode(block.basefee));
```

❌ **Noisy Traps:**
- Triggers every few blocks
- No practical use case
- Wastes operator resources

---

## Examples: Good vs Bad Traps

### ❌ Bad Example: Always-Respond Trap

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
- Triggers every 20 blocks (testnet) or 100 blocks (mainnet)
- Wastes gas constantly
- Provides no useful monitoring
- Adds noise to the network

### ✅ Good Example: Multivector Liquidity Monitor (Flexible Threshold)

```solidity
contract LiquidityDrainTrap is ITrap {
    IUniswapV2Pair public immutable pair;
    uint256 public constant DRAIN_THRESHOLD = 30; // 30% drop
    uint256 public constant TIME_WINDOW = 10; // blocks
    uint256 public constant EXTREME_DRAIN = 50; // 50% drop
    
    function collect() external view returns (bytes memory) {
        (uint112 reserve0, uint112 reserve1, uint32 timestamp) = pair.getReserves();
        return abi.encode(reserve0, reserve1, block.number, timestamp);
    }
    
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
        // Safety check
        if (data.length < 2) return (false, bytes(""));
        
        (uint112 oldReserve0, , uint256 oldBlock, ) = abi.decode(
            data[1], 
            (uint112, uint112, uint256, uint32)
        );
        (uint112 newReserve0, , uint256 newBlock, ) = abi.decode(
            data[0], 
            (uint112, uint112, uint256, uint32)
        );
        
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
        
        // Trigger if ANY 2 of 3 conditions met (flexible threshold)
        if (metConditions >= 2) {
            return (true, abi.encode(oldReserve0, newReserve0, blockDelta, metConditions));
        }
        
        return (false, bytes(""));
    }
}
```

**Why this is good:**
- Monitors specific vulnerability (liquidity drain)
- Has clear thresholds (30% and 50% drain, 10 block window)
- **Uses flexible triggering (ANY 2 of 3)**
- Triggers scenarios:
  * Significant drain (30%) + Recent (10 blocks) = TRIGGER
  * Significant drain (30%) + Extreme (50%) = TRIGGER
  * Recent (10 blocks) + Extreme (50%) = TRIGGER
- Only triggers on actual anomalies
- Provides actionable data
- Resilient to timing or measurement edge cases
- Proper safety checks for data array

### ✅ Good Example: Oracle Deviation Detector

```solidity
contract OracleDeviationTrap is ITrap {
    AggregatorV3Interface public immutable chainlinkFeed;
    IUniswapV2Pair public immutable uniswapPair;
    uint256 public constant DEVIATION_THRESHOLD = 5; // 5%
    
    function collect() external view returns (bytes memory) {
        // Get Chainlink price
        (, int256 chainlinkPrice, , , ) = chainlinkFeed.latestRoundData();
        
        // Get Uniswap price
        (uint112 reserve0, uint112 reserve1, ) = uniswapPair.getReserves();
        uint256 uniswapPrice = (uint256(reserve1) * 1e18) / uint256(reserve0);
        
        return abi.encode(uint256(chainlinkPrice), uniswapPrice, block.timestamp);
    }
    
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
        // Safety check
        if (data.length == 0 || data[0].length == 0) return (false, bytes(""));

        (uint256 chainlinkPrice, uint256 uniswapPrice, ) = abi.decode(
            data[0], 
            (uint256, uint256, uint256)
        );
        
        // Calculate deviation percentage
        uint256 diff = chainlinkPrice > uniswapPrice 
            ? chainlinkPrice - uniswapPrice 
            : uniswapPrice - chainlinkPrice;
        uint256 deviationPercent = (diff * 100) / chainlinkPrice;
        
        if (deviationPercent >= DEVIATION_THRESHOLD) {
            return (true, abi.encode(chainlinkPrice, uniswapPrice, deviationPercent));
        }
        
        return (false, bytes(""));
    }
}
```

**Why this is good:**
- Monitors critical infrastructure (oracle prices)
- Compares multiple data sources (multivector)
- Has meaningful threshold (5% deviation)
- Detects potential price manipulation or oracle issues
- Quiet by default, loud when critical
- Includes proper safety checks
- Uses correct `bytes[]` signature

---

## Additional Resources

- **[Drosera Documentation](https://docs.drosera.io)** - Official network docs
- **[Foundry Book](https://book.getfoundry.sh)** - Smart contract development
- **[Solidity Documentation](https://docs.soliditylang.org)** - Language reference
- **[Discord Community](https://discord.gg/drosera)** - Get help and support

---

**[← Back to Quick Start](README.md)**
