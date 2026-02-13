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
7. [Common Patterns Library](#common-patterns-library)
8. [Debugging Workflow](#debugging-workflow)
9. [Trap Quality Standards](#trap-quality-standards)
10. [Examples: Good vs Bad Traps](#examples-good-vs-bad-traps)
11. [Advanced Topics](#advanced-topics)

---

## Prerequisites

### Essential Requirements

- **Ubuntu VPS** with SSH access (or similar Linux environment)
- **Ethereum wallet** with private key
- **GitHub account**
- **Drosera operator running** (Cadet and Corporal roles completed)
- **Basic terminal familiarity**

### Verify Operator Status

Before starting, confirm your operator is running:

```bash
systemctl status drosera-operator
```

**Expected output:** Should show `active (running)` in green

If not running:
```bash
systemctl start drosera-operator
systemctl enable drosera-operator
```

### Check Drosera Installation

```bash
drosera --version
```

**Expected output:** Version number (e.g., `drosera 0.x.x`)

If not installed, refer to [Drosera Documentation](https://docs.drosera.io/installation)

### Network Selection

**Hoodi Testnet:**
- **Purpose:** Learning and testing trap logic
- **Complexity:** Simple patterns, simulated data
- **Requirements:** Testnet ETH from faucet
- **RPC:** `https://rpc.hoodi.ethpandaops.io/`
- **Chain ID:** `560048`
- **Drosera Address:** `0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D`

**Ethereum Mainnet:**
- **Purpose:** Production monitoring of real protocols
- **Complexity:** Multi-vector monitoring, real vulnerabilities
- **Requirements:** ~0.01-0.05 ETH for deployment gas
- **RPC:** `https://eth.llamarpc.com`
- **Chain ID:** `1`
- **Drosera Address:** `0x0c4f7e9684a11805Fc5406989F5124bFC2AD0D84`

### Wallet Setup

Ensure you have:
- **Private key** (64 hex characters, starting with 0x)
- **Gas funds:**
  - Hoodi: Small amount of testnet ETH (get from faucet)
  - Mainnet: 0.01-0.05 ETH for contract deployment

**Check balance:**
```bash
# For Hoodi
cast balance YOUR_ADDRESS --rpc-url https://rpc.hoodi.ethpandaops.io

# For Mainnet
cast balance YOUR_ADDRESS --rpc-url https://eth.llamarpc.com
```

---

## Phase 1: Local Development

### Step 1: Screen Session (Recommended)

Preserve your work if SSH connection drops:

```bash
screen -S drosera
```

**To detach:** Press `Ctrl+A`, then `D`

**To reattach if disconnected:**
```bash
screen -r drosera
```

**To exit screen permanently:**
```bash
exit
```

### Step 2: Project Setup

Replace `{folder-name}` with your trap's kebab-case name (e.g., `oracle-deviation-trap`):

```bash
# Navigate to home directory
cd ~

# Create project directory
mkdir {folder-name}

# Navigate into it
cd {folder-name}

# Verify you're in the right place
pwd
```

**Expected output:** `/home/your-username/{folder-name}`

Initialize Foundry project:

```bash
forge init
```

**Expected output:** 
```
Initializing /home/your-username/{folder-name}...
Installing forge-std in /home/your-username/{folder-name}/lib/forge-std...
```

Clean up default files:

```bash
rm src/Counter.sol script/Counter.s.sol test/Counter.t.sol
```

Verify cleanup:

```bash
ls src/
ls script/
ls test/
```

**Expected output:** Directories should be empty

### Step 3: Install Dependencies

#### Install Foundry (if not already installed)

```bash
curl -L https://foundry.paradigm.xyz | bash
source ~/.bashrc
foundryup
```

**Verify Foundry installation:**
```bash
forge --version
cast --version
```

#### Install Required Libraries

```bash
# Install Forge Standard Library
forge install foundry-rs/forge-std@v1.8.2 --no-commit

# Install OpenZeppelin Contracts
forge install OpenZeppelin/openzeppelin-contracts@v5.0.2 --no-commit
```

**Verify installations:**
```bash
ls lib/
```

**Expected output:** 
```
forge-std
openzeppelin-contracts
```

### Step 4: Create ITrap Interface

**Critical Step:** Create the exact interface Drosera expects.

```bash
# Create directory structure
mkdir -p lib/drosera-contracts/interfaces

# Create and edit interface file
nano lib/drosera-contracts/interfaces/ITrap.sol
```

**Paste this EXACT code** (do not modify):

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITrap {
    function collect() external view returns (bytes memory);
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory);
}
```

**Save and exit nano:**
- Press `Ctrl+X`
- Press `Y` (to confirm save)
- Press `Enter` (to confirm filename)

**Verify file was created correctly:**
```bash
cat lib/drosera-contracts/interfaces/ITrap.sol
```

**Expected output:** Should show the exact interface code you pasted

**⚠️ CRITICAL NOTES:**
- `shouldRespond` takes `bytes[]` (array), NOT `bytes` (singular)
- `collect()` is `view`, NOT `pure`
- `shouldRespond()` is `pure`, NOT `view`
- These requirements are non-negotiable for Drosera compatibility

### Step 5: Configure Remappings

```bash
nano remappings.txt
```

**Paste this configuration:**

```
drosera-contracts/=lib/drosera-contracts/
forge-std/=lib/forge-std/src/
openzeppelin-contracts/=lib/openzeppelin-contracts/
@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/
ds-test/=lib/openzeppelin-contracts/lib/forge-std/lib/ds-test/src/
erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/
halmos-cheatcodes/=lib/openzeppelin-contracts/lib/halmos-cheatcodes/src/
```

**Save:** `Ctrl+X`, `Y`, `Enter`

**Verify:**
```bash
cat remappings.txt
```

### Step 6: Configure Foundry

```bash
nano foundry.toml
```

**Paste this configuration:**

```toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
solc = "0.8.20"
optimizer = true
optimizer_runs = 200
```

**Save:** `Ctrl+X`, `Y`, `Enter`

**Verify:**
```bash
cat foundry.toml
```

### Step 7: Create Contract Files

You have two options:
1. **Use AI Copilot** (recommended for beginners) - See [copilot prompt](link)
2. **Write manually** - Follow the templates below

#### Option A: For Hoodi Testnet (Simulation Pattern)

**1. Create MockTarget Contract** (simulates vulnerable protocol):

```bash
nano src/MockTarget.sol
```

**Example MockTarget:**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title MockTarget
 * @notice Simulates a vulnerable DeFi protocol for testing trap logic on Hoodi testnet
 */
contract MockTarget {
    // Simulated state that trap will monitor
    uint256 public currentPrice = 1000 * 10**18; // $1000
    uint256 public baselinePrice = 1000 * 10**18;
    bool public priceDeviationDetected = false;
    
    address public owner;
    
    event PriceUpdated(uint256 newPrice);
    event DeviationFlagSet(bool status);
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    // Helper function to simulate price change
    function setPrice(uint256 _newPrice) external onlyOwner {
        currentPrice = _newPrice;
        emit PriceUpdated(_newPrice);
    }
    
    // Helper function to trigger trap condition
    function setPriceDeviationDetected(bool _status) external onlyOwner {
        priceDeviationDetected = _status;
        emit DeviationFlagSet(_status);
    }
    
    // Function trap can call to check conditions
    function checkPriceDeviation() external view returns (bool) {
        if (currentPrice == 0 || baselinePrice == 0) return false;
        
        uint256 deviation = currentPrice > baselinePrice
            ? ((currentPrice - baselinePrice) * 100) / baselinePrice
            : ((baselinePrice - currentPrice) * 100) / baselinePrice;
            
        return deviation > 5; // >5% deviation
    }
}
```

**Save:** `Ctrl+X`, `Y`, `Enter`

**2. Create Trap Contract:**

```bash
nano src/MockPriceDeviationTrap.sol
```

**Example Trap:**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "drosera-contracts/interfaces/ITrap.sol";

/**
 * @title MockPriceDeviationTrap
 * @notice Monitors MockTarget for simulated price deviations on Hoodi testnet
 */
contract MockPriceDeviationTrap is ITrap {
    
    address public immutable mockTarget;
    
    constructor(address _mockTarget) {
        require(_mockTarget != address(0), "Invalid target");
        mockTarget = _mockTarget;
    }
    
    /**
     * @notice Collects monitoring data from MockTarget
     * @dev MUST be view, NOT pure
     */
    function collect() external view override returns (bytes memory) {
        // Call MockTarget to get current state
        (bool success, bytes memory data) = mockTarget.staticcall(
            abi.encodeWithSignature("currentPrice()")
        );
        require(success, "Failed to get price");
        uint256 currentPrice = abi.decode(data, (uint256));
        
        (success, data) = mockTarget.staticcall(
            abi.encodeWithSignature("priceDeviationDetected()")
        );
        require(success, "Failed to get deviation flag");
        bool deviationDetected = abi.decode(data, (bool));
        
        return abi.encode(
            currentPrice,
            deviationDetected,
            block.number,
            block.timestamp
        );
    }
    
    /**
     * @notice Evaluates if response should be triggered
     * @dev MUST be pure, NOT view
     * @param data Array of historical monitoring data (data[0] is newest)
     */
    function shouldRespond(bytes[] calldata data) 
        external 
        pure 
        override 
        returns (bool, bytes memory) 
    {
        // CRITICAL: Always check data exists before decoding
        if (data.length == 0 || data[0].length == 0) {
            return (false, bytes(""));
        }
        
        // Decode newest data (index 0)
        (
            uint256 currentPrice,
            bool deviationDetected,
            uint256 blockNumber,
            uint256 timestamp
        ) = abi.decode(data[0], (uint256, bool, uint256, uint256));
        
        // Trigger if deviation flag is set
        if (deviationDetected) {
            return (
                true, 
                abi.encode(currentPrice, blockNumber, timestamp)
            );
        }
        
        // Default: no response needed
        return (false, bytes(""));
    }
}
```

**Save:** `Ctrl+X`, `Y`, `Enter`

**3. Create Response Contract:**

```bash
nano src/MockPriceDeviationResponse.sol
```

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title MockPriceDeviationResponse
 * @notice Handles alerts from MockPriceDeviationTrap
 */
contract MockPriceDeviationResponse {
    
    address public owner;
    mapping(address => bool) public authorizedOperators;
    
    event DeviationAlertReceived(
        uint256 currentPrice,
        uint256 blockNumber,
        uint256 timestamp,
        address indexed caller
    );
    
    constructor() {
        owner = msg.sender;
        authorizedOperators[msg.sender] = true; // Owner is authorized by default
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    modifier onlyOperator() {
        require(authorizedOperators[msg.sender], "Not authorized operator");
        _;
    }
    
    /**
     * @notice Authorize or deauthorize an operator
     * @param operator Address to authorize
     * @param authorized True to authorize, false to revoke
     */
    function setOperator(address operator, bool authorized) external onlyOwner {
        require(operator != address(0), "Invalid address");
        authorizedOperators[operator] = authorized;
    }
    
    /**
     * @notice Handles price deviation alerts
     * @dev Called by Drosera executor/operator, NOT by trap contract
     * @param payload Encoded data from trap's shouldRespond
     */
    function handleDeviation(bytes calldata payload) external onlyOperator {
        (uint256 currentPrice, uint256 blockNumber, uint256 timestamp) = 
            abi.decode(payload, (uint256, uint256, uint256));
        
        emit DeviationAlertReceived(currentPrice, blockNumber, timestamp, msg.sender);
        
        // In production, you might:
        // - Pause the protocol
        // - Update oracle
        // - Trigger emergency procedures
    }
}
```

**Save:** `Ctrl+X`, `Y`, `Enter`

**4. Create Deployment Script:**

```bash
nano script/Deploy.sol
```

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/MockTarget.sol";
import "../src/MockPriceDeviationResponse.sol";

contract DeployScript is Script {
    function run() external {
        vm.startBroadcast();
        
        // 1. Deploy MockTarget (simulated vulnerable protocol)
        MockTarget mockTarget = new MockTarget();
        console.log("MockTarget deployed at:", address(mockTarget));
        
        // 2. Deploy Response contract
        MockPriceDeviationResponse response = new MockPriceDeviationResponse();
        console.log("Response deployed at:", address(response));
        
        // 3. IMPORTANT: Do NOT deploy the Trap contract
        // Drosera reads trap logic from compiled artifact (out/ directory)
        // Deploying it manually will cause conflicts
        
        vm.stopBroadcast();
        
        console.log("\n=== DEPLOYMENT SUMMARY ===");
        console.log("MockTarget:", address(mockTarget));
        console.log("Response:", address(response));
        console.log("\nNext steps:");
        console.log("1. Copy the MockTarget address");
        console.log("2. Update drosera.toml with Response address");
        console.log("3. Run: drosera dryrun");
        console.log("4. Run: drosera apply");
    }
}
```

**Save:** `Ctrl+X`, `Y`, `Enter`

#### Option B: For Mainnet (Real Protocol Monitoring)

**1. Create Trap Contract** (example: Chainlink oracle staleness):

```bash
nano src/OracleStalenessT rap.sol
```

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "drosera-contracts/interfaces/ITrap.sol";

interface AggregatorV3Interface {
    function latestRoundData() external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );
}

/**
 * @title OracleStalenessTrap
 * @notice Monitors Chainlink oracle for stale price feeds
 */
contract OracleStalenessT rap is ITrap {
    
    AggregatorV3Interface public immutable priceFeed;
    uint256 public constant STALENESS_THRESHOLD = 3600; // 1 hour in seconds
    
    constructor(address _priceFeed) {
        require(_priceFeed != address(0), "Invalid feed");
        priceFeed = AggregatorV3Interface(_priceFeed);
    }
    
    /**
     * @notice Collects latest oracle data
     * @dev MUST be view, NOT pure
     */
    function collect() external view override returns (bytes memory) {
        (
            uint80 roundId,
            int256 answer,
            ,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        
        return abi.encode(
            roundId,
            answer,
            updatedAt,
            answeredInRound,
            block.timestamp
        );
    }
    
    /**
     * @notice Checks if oracle data is stale
     * @dev MUST be pure, NOT view
     */
    function shouldRespond(bytes[] calldata data) 
        external 
        pure 
        override 
        returns (bool, bytes memory) 
    {
        // CRITICAL: Always check data exists
        if (data.length == 0 || data[0].length == 0) {
            return (false, bytes(""));
        }
        
        (
            uint80 roundId,
            int256 answer,
            uint256 updatedAt,
            uint80 answeredInRound,
            uint256 currentTime
        ) = abi.decode(data[0], (uint80, int256, uint256, uint80, uint256));
        
        // Check if data is stale
        uint256 timeSinceUpdate = currentTime - updatedAt;
        
        // Check if round is valid
        bool invalidRound = answeredInRound < roundId;
        
        if (timeSinceUpdate > STALENESS_THRESHOLD || invalidRound) {
            return (
                true,
                abi.encode(roundId, answer, updatedAt, timeSinceUpdate)
            );
        }
        
        return (false, bytes(""));
    }
}
```

**Save:** `Ctrl+X`, `Y`, `Enter`

**2. Create Response Contract:**

```bash
nano src/OracleStalenessResponse.sol
```

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title OracleStalenessResponse
 * @notice Handles stale oracle alerts
 */
contract OracleStalenessResponse {
    
    address public owner;
    mapping(address => bool) public authorizedOperators;
    
    event StaleOracleDetected(
        uint80 roundId,
        int256 price,
        uint256 lastUpdate,
        uint256 staleDuration,
        address indexed caller
    );
    
    constructor() {
        owner = msg.sender;
        authorizedOperators[msg.sender] = true;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    modifier onlyOperator() {
        require(authorizedOperators[msg.sender], "Not authorized");
        _;
    }
    
    function setOperator(address operator, bool authorized) external onlyOwner {
        require(operator != address(0), "Invalid address");
        authorizedOperators[operator] = authorized;
    }
    
    /**
     * @notice Handles stale oracle alerts
     * @param payload Encoded data from trap
     */
    function handleStaleness(bytes calldata payload) external onlyOperator {
        (
            uint80 roundId,
            int256 price,
            uint256 lastUpdate,
            uint256 staleDuration
        ) = abi.decode(payload, (uint80, int256, uint256, uint256));
        
        emit StaleOracleDetected(
            roundId,
            price,
            lastUpdate,
            staleDuration,
            msg.sender
        );
    }
}
```

**Save:** `Ctrl+X`, `Y`, `Enter`

**3. Create Deployment Script:**

```bash
nano script/Deploy.sol
```

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/OracleStalenessResponse.sol";

contract DeployScript is Script {
    function run() external {
        vm.startBroadcast();
        
        // Deploy ONLY the Response contract
        OracleStalenessResponse response = new OracleStalenessResponse();
        console.log("Response deployed at:", address(response));
        
        // DO NOT deploy the Trap contract
        // Drosera reads it from compiled artifact
        
        vm.stopBroadcast();
        
        console.log("\n=== DEPLOYMENT SUMMARY ===");
        console.log("Response:", address(response));
        console.log("\nNext steps:");
        console.log("1. Copy the Response address");
        console.log("2. Update drosera.toml with Response address");
        console.log("3. Run: drosera dryrun");
        console.log("4. Run: drosera apply");
    }
}
```

**Save:** `Ctrl+X`, `Y`, `Enter`

### Step 8: Compile Contracts

```bash
forge build
```

**Expected output:**
```
[⠊] Compiling...
[⠒] Compiling 3 files with 0.8.20
[⠑] Solc 0.8.20 finished in 2.34s
Compiler run successful!
```

**If compilation fails**, see [Troubleshooting: Compilation Errors](#1-compilation-errors)

**Verify compiled artifacts:**

```bash
ls out/
```

**Expected output:** Should see folders for each contract

```bash
# Check specific trap artifact
ls out/YourTrapName.sol/
```

**Expected output:** Should see `YourTrapName.json`

**Verify trap JSON artifact exists:**
```bash
cat out/YourTrapName.sol/YourTrapName.json | head -20
```

**Expected output:** Should show JSON with ABI, bytecode, etc.

### Step 9: Environment Setup

```bash
nano .env
```

**Add your credentials:**

```
# Private key (64 hex characters, with or without 0x prefix)
PRIVATE_KEY=your_private_key_here

# For Hoodi Testnet
RPC_URL=https://rpc.hoodi.ethpandaops.io

# For Mainnet (uncomment when ready)
# RPC_URL=https://eth.llamarpc.com
```

**Save:** `Ctrl+X`, `Y`, `Enter`

**Secure the file:**
```bash
chmod 600 .env
```

**Load environment variables:**
```bash
source .env
```

**Verify (without exposing private key):**
```bash
echo "RPC_URL: $RPC_URL"
# Should NOT echo PRIVATE_KEY for security
```

### Step 10: Deploy Response Contract

**Load environment:**
```bash
source .env
```

**For Hoodi Testnet:**
```bash
forge script script/Deploy.sol \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --legacy
```

**For Ethereum Mainnet:**
```bash
forge script script/Deploy.sol \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify
```

**Expected output:**
```
== Logs ==
  MockTarget deployed at: 0xABC...123
  Response deployed at: 0xDEF...456

== Return ==
0: ...

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
```

**CRITICAL: Copy the Response contract address from output**

**Verify deployment:**
```bash
# Check if contract exists at address
cast code YOUR_RESPONSE_ADDRESS --rpc-url $RPC_URL
```

**Expected output:** Should show bytecode (long hex string)

If you see `0x`, the contract was NOT deployed. Check for errors.

---

## Phase 2: Drosera Integration

### Step 1: Create drosera.toml Configuration

**Navigate to project directory:**
```bash
cd ~/{your-folder-name}
pwd  # Verify you're in the right place
```

**Create configuration file:**
```bash
nano drosera.toml
```

#### For Hoodi Testnet:

```toml
# Network Configuration
ethereum_rpc = "https://rpc.hoodi.ethpandaops.io/"
drosera_rpc = "https://relay.hoodi.drosera.io"
eth_chain_id = 560048
drosera_address = "0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D"

# Trap Configuration
[traps]
[traps.your_trap_snake_case]  # Replace with your trap name in snake_case

# Path to compiled trap artifact
path = "out/YourTrapName.sol/YourTrapName.json"

# Response contract address (from deployment output)
response_contract = "0xYOUR_RESPONSE_ADDRESS_HERE"

# Response function signature (must match EXACTLY)
# Format: "functionName(type1,type2,type3)"
response_function = "handleAlert(uint256,uint256,uint256)"

# Network parameters for Hoodi
cooldown_period_blocks = 33          # Minimum blocks between responses
min_number_of_operators = 1          # Minimum operators needed
max_number_of_operators = 3          # Maximum operators allowed
block_sample_size = 1                # Number of historical blocks to check

# Privacy settings
private = true
whitelist = ["YOUR_WALLET_ADDRESS"]  # Your operator address
private_trap = true

# CRITICAL: Do NOT add 'address = ...' here
# Drosera will auto-deploy the trap and fill this field
```

#### For Ethereum Mainnet:

```toml
# Network Configuration
ethereum_rpc = "https://eth.llamarpc.com"
drosera_rpc = "https://relay.mainnet.drosera.io"
eth_chain_id = 1
drosera_address = "0x0c4f7e9684a11805Fc5406989F5124bFC2AD0D84"

# Trap Configuration
[traps]
[traps.your_trap_snake_case]  # Replace with your trap name in snake_case

# Path to compiled trap artifact
path = "out/YourTrapName.sol/YourTrapName.json"

# Response contract address (from deployment output)
response_contract = "0xYOUR_RESPONSE_ADDRESS_HERE"

# Response function signature (must match EXACTLY)
response_function = "handleAlert(uint256,uint256,uint256)"

# Network parameters for Mainnet
cooldown_period_blocks = 100         # Minimum blocks between responses
min_number_of_operators = 2          # Minimum operators needed
max_number_of_operators = 5          # Maximum operators allowed
block_sample_size = 1                # Number of historical blocks to check

# Privacy settings
private = true
whitelist = ["YOUR_WALLET_ADDRESS"]  # Your operator address
private_trap = true

# CRITICAL: Do NOT add 'address = ...' here
# Drosera will auto-deploy the trap and fill this field
```

**Parameter Explanations:**

- **`path`**: Location of compiled trap JSON artifact
- **`response_contract`**: Address where Response contract is deployed
- **`response_function`**: EXACT function signature from Response contract
  - Format: `"functionName(type1,type2,type3)"`
  - No spaces, must match Response contract exactly
  - Example: `"handleAlert(uint256,uint256,uint256)"`
- **`cooldown_period_blocks`**: Minimum blocks between trap responses (prevents spam)
- **`block_sample_size`**: How many historical blocks to pass to `shouldRespond()`
  - `1` = Only current block
  - `3-10` = Historical analysis (requires loop in shouldRespond)
- **`min/max_number_of_operators`**: Operator consensus requirements
- **`whitelist`**: Your operator wallet address (check with `drosera operator info`)

**Save:** `Ctrl+X`, `Y`, `Enter`

**Verify configuration:**
```bash
cat drosera.toml
```

### Step 2: Verify Response Function Signature

**CRITICAL:** The `response_function` in TOML must EXACTLY match your Response contract.

**Check your Response contract:**
```bash
grep "function" src/YourResponse.sol
```

**Example output:**
```solidity
function handleAlert(uint256 price, uint256 blockNum, uint256 timestamp) external onlyOperator {
```

**Corresponding TOML entry:**
```toml
response_function = "handleAlert(uint256,uint256,uint256)"
```

**Common mistakes:**
- ❌ `"handleAlert(uint256, uint256, uint256)"` - Has spaces
- ❌ `"handleAlert(uint256)"` - Wrong number of params
- ❌ `"handleDeviation(uint256,uint256,uint256)"` - Wrong function name
- ✅ `"handleAlert(uint256,uint256,uint256)"` - Correct

### Step 3: Test Configuration (Dry Run)

```bash
drosera dryrun
```

**Expected output (success):**
```
✓ Configuration valid
✓ Trap artifact found
✓ Response contract exists
✓ Planning successful
```

**If you see errors**, see [Troubleshooting](#troubleshooting) section

**Common dryrun errors:**
- "Response contract not found" → Wrong address in TOML
- "Function selector mismatch" → response_function doesn't match contract
- "Invalid artifact path" → Check path in TOML
- "Planning failed: execution reverted" → ABI mismatch or authorization issue

### Step 4: Deploy Trap to Drosera

**Load private key:**
```bash
source .env
```

**Deploy:**
```bash
DROSERA_PRIVATE_KEY=$PRIVATE_KEY drosera apply
```

**Expected output:**
```
Deploying trap...
✓ Trap deployed at: 0xABC123...
✓ Configuration updated
✓ Trap registered with operators
```

**IMPORTANT:** Drosera automatically:
1. Deploys your Trap contract
2. Updates `drosera.toml` with the trap address
3. Registers trap with operator network

**Verify trap address was added:**
```bash
cat drosera.toml | grep "address ="
```

**Expected output:**
```toml
address = "0xABC123DEF456..."
```

**If you see errors**, see [Troubleshooting: Drosera Apply Errors](#3-drosera-apply-errors)

### Step 5: Authorize Operator in Response Contract

**CRITICAL STEP:** Your Response contract needs to authorize the Drosera operator.

**Find your operator address:**
```bash
drosera operator info
```

**Or check your whitelist from TOML:**
```bash
cat drosera.toml | grep whitelist
```

**Authorize operator in Response contract:**

```bash
# Using cast to call setOperator function
cast send YOUR_RESPONSE_ADDRESS \
  "setOperator(address,bool)" \
  YOUR_OPERATOR_ADDRESS \
  true \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY
```

**Verify authorization:**
```bash
cast call YOUR_RESPONSE_ADDRESS \
  "authorizedOperators(address)(bool)" \
  YOUR_OPERATOR_ADDRESS \
  --rpc-url $RPC_URL
```

**Expected output:** `true` (as hex: `0x0000000000000000000000000000000000000000000000000000000000000001`)

---

## Phase 3: GitHub Publication

### Step 1: Create .gitignore

```bash
cd ~/{your-folder-name}
nano .gitignore
```

**Paste:**
```
# Sensitive files
.env
*.key

# Build artifacts
out/
cache/
broadcast/

# Dependencies
lib/
node_modules/

# OS files
.DS_Store
*.swp
*~

# IDE
.vscode/
.idea/
```

**Save:** `Ctrl+X`, `Y`, `Enter`

### Step 2: Generate README

```bash
nano README.md
```

#### For Hoodi Testnet (Learning Template):

```markdown
# [Your Trap Name] - Learning Template

> Educational trap demonstrating [concept] monitoring on Hoodi testnet

## Overview

This trap demonstrates how to monitor [specific pattern] using Drosera's monitoring infrastructure. It's designed for learning and testing trap logic in a safe environment.

## What It Monitors

- **MockTarget Contract**: Simulates a vulnerable DeFi protocol
- **Monitoring Pattern**: [Describe what conditions trigger the trap]
- **Response Action**: [What happens when triggered]

## How to Test

1. Deploy the MockTarget contract
2. Trigger test conditions:
   ```bash
   cast send MOCK_TARGET_ADDRESS \
     "setPriceDeviationDetected(bool)" \
     true \
     --rpc-url https://rpc.hoodi.ethpandaops.io \
     --private-key $PRIVATE_KEY
   ```
3. Monitor dashboard for trap activation

## Educational Value

This trap teaches:
- ✅ How to implement ITrap interface
- ✅ Data collection with `collect()`
- ✅ Condition evaluation with `shouldRespond()`
- ✅ Safe data handling with length guards
- ✅ Proper ABI encoding/decoding

## Contract Addresses

- **MockTarget**: `0x...`
- **Response**: `0x...`
- **Trap**: `0x...` (auto-deployed by Drosera)

## Deployment

- **Network**: Hoodi Testnet
- **Block Sample Size**: 1
- **Cooldown**: 33 blocks

## Next Steps

Use this template to build production traps for Ethereum mainnet by:
1. Replacing MockTarget with real protocol interfaces
2. Implementing multivector monitoring logic
3. Adding flexible threshold patterns
```

#### For Ethereum Mainnet (Production):

```markdown
# [Your Trap Name]

> Production monitoring trap for [protocol/vulnerability]

## Overview

This trap monitors [specific DeFi protocol/vulnerability] on Ethereum mainnet, providing early warning for [specific attack vector or risk].

## What It Detects

**Vulnerability**: [Describe the specific vulnerability]

**Monitoring Vectors**:
- 🎯 [Vector 1]: [Description]
- 🎯 [Vector 2]: [Description]
- 🎯 [Vector 3]: [Description] (if applicable)

**Trigger Conditions**:
- [Condition 1]
- [Condition 2]
- Flexible threshold: Triggers if ANY 2 of 3 conditions met

## Value Proposition

**Why This Matters**:
- Protects [asset type] worth $XXM TVL
- Detects [attack type] before execution
- Historical precedent: [Similar exploit that occurred]

**Who Benefits**:
- Protocol treasuries
- LPs in affected pools
- DeFi users with exposure

## Technical Details

**Protocol Monitored**: [Protocol name]
**Contracts**: [Addresses]
**Data Sources**: [Oracles, DEXs, etc.]

**Trigger Logic**:
```solidity
// Pseudocode
if (condition1 && condition2) OR 
   (condition1 && condition3) OR 
   (condition2 && condition3) {
    trigger response
}
```

## Efficiency Design

**Silent Watchdog Pattern**:
- ✅ Returns `false` under normal conditions
- ✅ Only triggers on critical anomalies
- ✅ Low gas consumption for operators
- ✅ Cooldown prevents spam (100 blocks)

**Expected Behavior**:
- Normal: Green blocks, no responses
- Attack: Red block, response triggered
- False positive rate: <0.1%

## Contract Addresses

- **Response Contract**: `0x...`
- **Trap Contract**: `0x...` (Drosera-deployed)
- **Monitored Protocol**: `0x...`

## Deployment Details

- **Network**: Ethereum Mainnet
- **Block Sample Size**: [X] blocks
- **Cooldown**: 100 blocks
- **Operators**: 2-5 consensus

## Verification

Check trap status:
- Dashboard: [Link to Drosera dashboard]
- Green blocks = Monitoring successfully
- Red blocks = Response triggered

## Response Action

When triggered, the Response contract:
1. Emits alert event
2. [Additional actions if any]

## Development

Built using:
- Foundry
- Drosera SDK
- Solidity 0.8.20

## License

MIT
```

**Save:** `Ctrl+X`, `Y`, `Enter`

### Step 3: Git Initialization

```bash
# Initialize repository
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: [Your Trap Name]"
```

**Verify:**
```bash
git status
git log
```

### Step 4: Create GitHub Repository

1. Go to **https://github.com/new**
2. **Repository name**: `your-trap-kebab-case` (e.g., `oracle-staleness-trap`)
3. **Visibility**: Public
4. **Do NOT** initialize with README (you already have one)
5. Click **Create repository**

### Step 5: Generate GitHub Personal Access Token

1. Go to **https://github.com/settings/tokens**
2. Click **Generate new token (classic)**
3. **Note**: "Drosera Trap Deployment"
4. **Scopes**: Select `repo` and `workflow`
5. Click **Generate token**
6. **Copy the token** (you won't see it again)

**Add to environment:**
```bash
nano .env
```

**Add token:**
```
GITHUB_TOKEN=ghp_your_token_here
```

**Save:** `Ctrl+X`, `Y`, `Enter`

**Load:**
```bash
source .env
```

### Step 6: Push to GitHub

```bash
# Get your GitHub username
read -p "Enter your GitHub username: " GITHUB_USER

# Get repository name
read -p "Enter repository name (kebab-case): " REPO_NAME

# Add remote
git remote add origin https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${REPO_NAME}.git

# Rename branch to main
git branch -M main

# Push
git push -u origin main
```

**Expected output:**
```
Enumerating objects: ...
Counting objects: 100% ...
Writing objects: 100% ...
To https://github.com/your-username/your-repo.git
 * [new branch]      main -> main
```

### Step 7: Verify GitHub Publication

**Check repository:**
```bash
echo "https://github.com/${GITHUB_USER}/${REPO_NAME}"
```

Visit the URL and verify:
- ✅ README displays correctly
- ✅ All contract files present
- ✅ No `.env` file visible (should be in .gitignore)

---

## Phase 4: Dashboard Verification

### Step 1: Access Drosera Dashboard

Navigate to your Drosera operator dashboard (URL provided during operator setup)

### Step 2: Locate Your Trap

Look for your trap in the traps list:
- Name should match your snake_case name from TOML
- Status should show "Active"

### Step 3: Understand Block Colors

**Green Blocks**:
- ✅ Trap is monitoring successfully
- ✅ `shouldRespond()` returned `false` (no threat detected)
- ✅ This is normal and expected most of the time

**Red Blocks**:
- ⚠️ `shouldRespond()` returned `true` (threat detected!)
- ⚠️ Response was triggered
- ⚠️ OR an error occurred in trap logic

**Gray/No Blocks**:
- ⚠️ Trap is not being executed
- Check operator status
- Check TOML configuration

### Step 4: Verify Monitoring Frequency

**Expected behavior:**

**Hoodi Testnet:**
- New block every ~12 seconds
- Trap checked every 33 blocks minimum (cooldown)
- You should see steady green blocks

**Ethereum Mainnet:**
- New block every ~12 seconds
- Trap checked every 100 blocks minimum (cooldown)
- Approximately every 20 minutes

### Step 5: Check Operator Logs

```bash
# View recent operator logs
journalctl -u drosera-operator -n 100 --no-pager

# Follow logs in real-time
journalctl -u drosera-operator -f
```

**Look for:**
- "Executing trap: your_trap_name"
- "Trap result: false" (good - no threat)
- "Trap result: true" (alert - threat detected)
- Any error messages

**Exit log view:** `Ctrl+C`

### Step 6: Test Trap (Hoodi Only)

If on Hoodi testnet with MockTarget:

```bash
# Trigger the trap condition
cast send YOUR_MOCKTARGET_ADDRESS \
  "setPriceDeviationDetected(bool)" \
  true \
  --rpc-url https://rpc.hoodi.ethpandaops.io \
  --private-key $PRIVATE_KEY

# Wait for next trap execution (cooldown_period_blocks)
# Watch dashboard for red block

# Reset condition
cast send YOUR_MOCKTARGET_ADDRESS \
  "setPriceDeviationDetected(bool)" \
  false \
  --rpc-url https://rpc.hoodi.ethpandaops.io \
  --private-key $PRIVATE_KEY
```

### Step 7: Success Confirmation

✅ **Your trap is successfully deployed if:**
- Trap appears in dashboard
- Green blocks are appearing regularly
- Operator logs show successful execution
- (Hoodi only) Test trigger causes red block

### Step 8: Submit for Verification

Once verified working:
1. Take screenshot of dashboard showing:
   - Trap name
   - Green blocks
   - Active status
2. Go to Drosera Discord
3. Create ticket in #verification channel
4. Submit:
   - Screenshot
   - GitHub repository link
   - Trap address
   - Network (Hoodi/Mainnet)

---

## Troubleshooting

### 1. Compilation Errors

#### Error: "Missing dependencies"

**Symptoms:**
```
Error: 
  0: Could not find forge-std/Test.sol
  1: lib/forge-std/src not found
```

**Fix:**
```bash
# Reinstall dependencies
forge install foundry-rs/forge-std@v1.8.2 --no-commit
forge install OpenZeppelin/openzeppelin-contracts@v5.0.2 --no-commit

# Verify installation
ls lib/forge-std
ls lib/openzeppelin-contracts
```

#### Error: "Wrong shouldRespond signature"

**Symptoms:**
```
Error: Interface mismatch
  function shouldRespond(bytes calldata data) ...
  Expected: function shouldRespond(bytes[] calldata data) ...
```

**Diagnosis:** Using `bytes` instead of `bytes[]` in shouldRespond

**Fix:**
```bash
nano src/YourTrap.sol
```

Change:
```solidity
// WRONG
function shouldRespond(bytes calldata data) external pure returns (bool, bytes memory)

// CORRECT
function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory)
```

**Save:** `Ctrl+X`, `Y`, `Enter`

```bash
forge build
```

#### Error: "pure != view" or "view != pure"

**Symptoms:**
```
Error: Function visibility mismatch
  collect() is pure but should be view
```

**Diagnosis:** Wrong visibility modifiers

**Fix:**
```bash
nano src/YourTrap.sol
```

Ensure:
```solidity
// collect() MUST be view (reads blockchain state)
function collect() external view override returns (bytes memory) {
    ...
}

// shouldRespond() MUST be pure (no state reads)
function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
    ...
}
```

**Save and rebuild:**
```bash
forge build
```

### 2. Storage Variable Error (CRITICAL)

**Symptoms:**
- Trap compiles but never triggers
- Always returns `false` even when conditions are met
- Dashboard shows green blocks constantly

**Diagnosis:** Trap contract has storage variables

**Why This Fails:**
Drosera redeploys your trap on a shadow-fork every block. All storage variables reset to their default values (zero/false). The trap's state never persists between blocks.

**Example of WRONG code:**
```solidity
contract BadTrap is ITrap {
    uint256 public lastPrice;  // ❌ STORAGE VARIABLE - Will reset every block!
    bool public alertTriggered;  // ❌ STORAGE VARIABLE - Will reset every block!
    
    function collect() external view returns (bytes memory) {
        lastPrice = getCurrentPrice();  // ❌ Tries to write to storage in view function
        return abi.encode(lastPrice);
    }
}
```

**Fix - Remove ALL storage variables:**
```solidity
contract GoodTrap is ITrap {
    // ✅ Use immutable for constructor-set values
    address public immutable targetContract;
    uint256 public constant THRESHOLD = 1000;  // ✅ Constants are OK
    
    constructor(address _target) {
        targetContract = _target;  // ✅ Set once in constructor
    }
    
    function collect() external view returns (bytes memory) {
        // ✅ Read current price directly, don't store it
        uint256 currentPrice = getCurrentPrice();
        return abi.encode(currentPrice, block.number, block.timestamp);
    }
    
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
        // ✅ Decode data passed in, don't read from storage
        (uint256 price, uint256 blockNum, uint256 timestamp) = abi.decode(
            data[0],
            (uint256, uint256, uint256)
        );
        
        if (price > THRESHOLD) {  // ✅ Compare against constant
            return (true, abi.encode(price, blockNum));
        }
        return (false, bytes(""));
    }
}
```

**Key Rules:**
- ✅ `constant` variables OK (compile-time values)
- ✅ `immutable` variables OK (set in constructor)
- ❌ `public` / `private` storage variables NOT OK
- ❌ State-changing operations NOT OK

### 3. ABI Mismatch (CRITICAL)

**Symptoms:**
```
Error: execution reverted
Location: crates/planning/transaction_builder.rs:123
```

**Diagnosis:** Trap returns data that doesn't match Response function parameters

**How ABI Wiring Works:**
1. Trap's `shouldRespond()` returns: `abi.encode(A, B, C)`
2. Drosera calls Response function with that encoded data
3. Response function must decode the SAME types: `function handle(A, B, C)`
4. TOML must specify the EXACT signature: `"handle(A,B,C)"`

**Example of ABI Mismatch:**

**Trap (WRONG):**
```solidity
function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
    return (true, abi.encode(uint256(100), uint256(200)));  // Returns 2 uint256
}
```

**Response (WRONG - doesn't match):**
```solidity
function handleAlert(uint256 value) external {  // Expects only 1 uint256!
    // This will REVERT - ABI mismatch
}
```

**Fix - Make them match:**

**Trap (CORRECT):**
```solidity
function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
    uint256 price = 100;
    uint256 timestamp = 200;
    return (true, abi.encode(price, timestamp));  // Returns 2 uint256
}
```

**Response (CORRECT - matches):**
```solidity
function handleAlert(uint256 price, uint256 timestamp) external {  // Expects 2 uint256
    // Decoding happens automatically - function receives both params
}
```

**TOML (CORRECT - matches):**
```toml
response_function = "handleAlert(uint256,uint256)"  # Signature matches Response function
```

**Verification Checklist:**
```bash
# 1. Check what Trap returns
grep "abi.encode" src/YourTrap.sol

# 2. Check Response function signature
grep "function" src/YourResponse.sol

# 3. Check TOML configuration
grep "response_function" drosera.toml

# All three MUST match!
```

### 4. Authorization Error (CRITICAL)

**Symptoms:**
```
Error: execution reverted
Reason: "not authorized" or "Only trap" or access control failure
```

**Diagnosis:** Response contract blocking the Drosera executor

**Common Mistake:**
```solidity
// ❌ WRONG - Trap contract doesn't call the Response
address public trapAddress;

modifier onlyTrap() {
    require(msg.sender == trapAddress, "Only trap can call");
    _;
}

function handleAlert(uint256 value) external onlyTrap {
    // This WILL FAIL because Drosera executor calls this, not the trap!
}
```

**How Drosera Actually Works:**
1. Operator runs `collect()` and `shouldRespond()` on trap
2. If `shouldRespond()` returns `true`, operator gets the payload
3. **Operator's wallet** calls `Response.yourFunction(payload)`
4. Trap contract is NEVER involved in calling Response

**Correct Authorization Pattern:**

```solidity
contract CorrectResponse {
    address public owner;
    mapping(address => bool) public authorizedOperators;
    
    event OperatorAuthorized(address indexed operator, bool authorized);
    event AlertHandled(uint256 value, address indexed caller);
    
    constructor() {
        owner = msg.sender;
        authorizedOperators[msg.sender] = true;  // Owner is auto-authorized
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    // ✅ CORRECT - Check if caller is authorized operator
    modifier onlyOperator() {
        require(authorizedOperators[msg.sender], "Not authorized operator");
        _;
    }
    
    // Function to authorize/deauthorize operators
    function setOperator(address operator, bool authorized) external onlyOwner {
        require(operator != address(0), "Invalid operator address");
        authorizedOperators[operator] = authorized;
        emit OperatorAuthorized(operator, authorized);
    }
    
    // ✅ CORRECT - Uses onlyOperator modifier
    function handleAlert(uint256 value) external onlyOperator {
        emit AlertHandled(value, msg.sender);
        // Your response logic here
    }
}
```

**After Deployment, You MUST Authorize Your Operator:**

```bash
# 1. Find your operator address
drosera operator info
# OR check your TOML whitelist
cat drosera.toml | grep whitelist

# 2. Authorize the operator
cast send YOUR_RESPONSE_ADDRESS \
  "setOperator(address,bool)" \
  YOUR_OPERATOR_ADDRESS \
  true \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY

# 3. Verify authorization
cast call YOUR_RESPONSE_ADDRESS \
  "authorizedOperators(address)(bool)" \
  YOUR_OPERATOR_ADDRESS \
  --rpc-url $RPC_URL

# Expected: true (hex: 0x0000...0001)
```

### 5. Data Length Guard Missing

**Symptoms:**
- Red blocks in dashboard
- Operator logs show "execution reverted"
- Error during `abi.decode()`

**Diagnosis:** Missing check for empty data before decoding

**Why This Happens:**
Drosera's planner may pass empty data arrays during validation or error scenarios. If you try to decode empty data, `abi.decode()` will revert.

**Example of WRONG code:**
```solidity
function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
    // ❌ Directly decoding without checking if data exists
    (uint256 price, uint256 timestamp) = abi.decode(data[0], (uint256, uint256));
    // This WILL REVERT if data is empty!
    
    if (price > 1000) {
        return (true, abi.encode(price));
    }
    return (false, bytes(""));
}
```

**CORRECT code - ALWAYS check data first:**
```solidity
function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
    // ✅ MANDATORY: Check if data exists before decoding
    if (data.length == 0 || data[0].length == 0) {
        return (false, bytes(""));  // Return safely without decoding
    }
    
    // ✅ Now safe to decode
    (uint256 price, uint256 timestamp) = abi.decode(data[0], (uint256, uint256));
    
    if (price > 1000) {
        return (true, abi.encode(price));
    }
    return (false, bytes(""));
}
```

**This check MUST be the first thing in shouldRespond():**
```solidity
if (data.length == 0 || data[0].length == 0) return (false, bytes(""));
```

### 6. TOML Address Field Error

**Symptoms:**
```
Error: Trap already exists
Error: Planning failed - invalid trap config
```

**Diagnosis:** Manually added `address = "0x..."` in drosera.toml

**Example of WRONG TOML:**
```toml
[traps.my_trap]
path = "out/MyTrap.sol/MyTrap.json"
response_contract = "0xABC..."
response_function = "handle(uint256)"
address = "0x123..."  # ❌ WRONG - You added this manually!
```

**Why This Fails:**
- `drosera apply` tries to use this as an existing trap
- If the address doesn't exist or is wrong, planning fails
- Drosera expects to deploy the trap itself and fill this field

**Fix:**
```bash
nano drosera.toml
```

**Remove the address line:**
```toml
[traps.my_trap]
path = "out/MyTrap.sol/MyTrap.json"
response_contract = "0xABC..."
response_function = "handle(uint256)"
# NO address field here - Drosera will add it after deployment
```

**Save:** `Ctrl+X`, `Y`, `Enter`

**Redeploy:**
```bash
DROSERA_PRIVATE_KEY=$PRIVATE_KEY drosera apply
```

**After successful deployment**, Drosera will automatically add:
```toml
address = "0xDROSERA_DEPLOYED_ADDRESS"
```

### 7. Response Contract Not Found

**Symptoms:**
```
Error: Response contract not found at address
Error: Invalid bytecode at response_contract
```

**Diagnosis:** Response contract not deployed OR wrong address in TOML

**Verification Steps:**

**1. Check if Response was deployed:**
```bash
# Look for deployment output
cat broadcast/Deploy.sol/*/run-latest.json | grep "contractAddress"
```

**2. Verify contract exists at address:**
```bash
cast code YOUR_RESPONSE_ADDRESS --rpc-url $RPC_URL
```

**Expected:** Long hex string (bytecode)
**If you see `0x`:** Contract does NOT exist at that address

**3. Check TOML has correct address:**
```bash
grep "response_contract" drosera.toml
```

**Fix:**

**If contract wasn't deployed:**
```bash
# Deploy Response contract
forge script script/Deploy.sol \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast

# Note the deployed address from output
```

**If wrong address in TOML:**
```bash
nano drosera.toml
```

Update:
```toml
response_contract = "0xCORRECT_RESPONSE_ADDRESS"
```

**Save and test:**
```bash
drosera dryrun
```

### 8. Block Sample Size Mismatch

**Symptoms:**
- Set `block_sample_size = 5` in TOML
- But trap only checks `data[0]`
- Not using historical data as intended

**Diagnosis:** shouldRespond not looping through data array

**Example - Not Using History:**
```solidity
// TOML: block_sample_size = 5
function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
    if (data.length == 0 || data[0].length == 0) return (false, bytes(""));
    
    (uint256 price) = abi.decode(data[0], (uint256));
    // ❌ Only checking current block (data[0]), ignoring historical data
    
    if (price > 1000) return (true, abi.encode(price));
    return (false, bytes(""));
}
```

**Fix - Use Historical Data:**
```solidity
// TOML: block_sample_size = 5
uint256 constant SAMPLE_SIZE = 5;
uint256 constant THRESHOLD = 1000;

function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
    if (data.length == 0 || data[0].length == 0) return (false, bytes(""));
    
    // ✅ Loop through historical samples
    uint256 breaches = 0;
    uint256 toCheck = data.length < SAMPLE_SIZE ? data.length : SAMPLE_SIZE;
    
    for (uint256 i = 0; i < toCheck; i++) {
        if (data[i].length == 0) continue;  // Skip empty samples
        
        (uint256 price) = abi.decode(data[i], (uint256));
        
        if (price > THRESHOLD) {
            breaches++;
        }
    }
    
    // Trigger if 3 out of 5 blocks breached threshold (sustained condition)
    if (breaches >= 3) {
        (uint256 currentPrice) = abi.decode(data[0], (uint256));
        return (true, abi.encode(currentPrice, breaches));
    }
    
    return (false, bytes(""));
}
```

**Data Array Structure:**
- `data[0]` = **Newest** block
- `data[1]` = Previous block
- `data[2]` = 2 blocks ago
- etc.

### 9. Trap Not Appearing in Dashboard

**Symptoms:**
- `drosera apply` succeeded
- But trap not showing in dashboard
- No blocks (green or red) appearing

**Diagnosis Steps:**

**1. Check operator is running:**
```bash
systemctl status drosera-operator
```

**Expected:** `active (running)`

**If not running:**
```bash
systemctl start drosera-operator
systemctl enable drosera-operator
```

**2. Check operator logs for trap:**
```bash
journalctl -u drosera-operator -n 100 | grep "your_trap_name"
```

**Look for:**
- "Registered trap: your_trap_name"
- "Executing trap: your_trap_name"

**3. Verify correct network in dashboard:**
- Make sure dashboard is set to correct network (Hoodi vs Mainnet)
- Check network switcher in dashboard UI

**4. Check TOML configuration:**
```bash
cat drosera.toml | grep -A 10 "\[traps"
```

**Verify:**
- Trap name matches
- `address = ...` line exists (filled by drosera apply)
- All parameters present

**5. Wait for network propagation:**
- Can take 1-5 minutes for trap to appear
- Refresh dashboard
- Check again in a few minutes

**6. Check whitelist:**
```bash
cat drosera.toml | grep "whitelist"
```

Ensure your operator address is in the whitelist.

### 10. Red Blocks (Errors vs Triggers)

**Red blocks can mean two things:**

**A. Response Triggered (Intended Behavior):**
- Trap detected anomaly
- `shouldRespond()` returned `true`
- Response function was called
- This is GOOD if it's a real threat

**B. Error in Trap Logic (Unintended):**
- `collect()` reverted
- `shouldRespond()` reverted
- External call failed
- This is BAD - needs fixing

**How to Diagnose:**

**Check operator logs:**
```bash
journalctl -u drosera-operator -n 50 | grep "your_trap_name"
```

**Look for:**
```
# Good (intended trigger):
Trap result: true
Response executed successfully

# Bad (error):
Trap execution failed: revert
Error in collect(): ...
Error in shouldRespond(): ...
```

**Common Causes of Error Red Blocks:**

1. **External call reverts in collect():**
```solidity
// If targetContract doesn't exist or function reverts
(bool success, bytes memory data) = targetContract.staticcall(...);
require(success, "Call failed");  // This will revert if call fails
```

**Fix:** Add error handling:
```solidity
(bool success, bytes memory data) = targetContract.staticcall(...);
if (!success) {
    return abi.encode(0, 0, 0);  // Return safe defaults instead of reverting
}
```

2. **Missing data length guard:**
```solidity
// Missing this check:
if (data.length == 0 || data[0].length == 0) return (false, bytes(""));
```

3. **Division by zero:**
```solidity
uint256 ratio = price / basePrice;  // If basePrice is 0, this reverts
```

**Fix:**
```solidity
if (basePrice == 0) return (false, bytes(""));
uint256 ratio = price / basePrice;
```

4. **Array out of bounds:**
```solidity
for (uint256 i = 0; i < 10; i++) {
    abi.decode(data[i], ...);  // If data.length < 10, this reverts
}
```

**Fix:**
```solidity
uint256 len = data.length < 10 ? data.length : 10;
for (uint256 i = 0; i < len; i++) {
    if (data[i].length == 0) continue;
    abi.decode(data[i], ...);
}
```

### 11. tx.gasprice Context Issue

**Symptoms:**
- Trap uses `tx.gasprice` in collect()
- Always returns 0 or incorrect values
- Gas price monitoring not working

**Diagnosis:** `collect()` runs via `eth_call`, not a real transaction

**Why This Fails:**
```solidity
function collect() external view returns (bytes memory) {
    uint256 gasPrice = tx.gasprice;  // ❌ This is 0 in eth_call context!
    return abi.encode(gasPrice);
}
```

When Drosera operators call `collect()`, they use `eth_call` (a read-only call). In this context:
- `tx.gasprice` is often 0
- `msg.value` is 0
- `msg.sender` is the operator's address
- You're not in a real transaction context

**Fix Option 1: Pass gas price via calldata tail**

```solidity
function collect() external view returns (bytes memory) {
    uint256 gasPrice = 0;
    
    // Operator can append gas price to calldata
    if (msg.data.length >= 4 + 32) {
        (gasPrice) = abi.decode(msg.data[4:], (uint256));
    }
    
    uint256 baseFee = block.basefee;  // ✅ This works - block.basefee is available
    uint256 ratio = baseFee == 0 ? 0 : (gasPrice * 1e18) / baseFee;
    
    return abi.encode(baseFee, gasPrice, ratio, block.number);
}
```

**Fix Option 2: Use block.basefee instead**

```solidity
function collect() external view returns (bytes memory) {
    uint256 baseFee = block.basefee;  // ✅ Use this instead of tx.gasprice
    return abi.encode(baseFee, block.number, block.timestamp);
}
```

**What you CAN reliably read in collect():**
- ✅ `block.number`
- ✅ `block.timestamp`
- ✅ `block.basefee`
- ✅ External contract state (via staticcall)
- ❌ `tx.gasprice` (unreliable)
- ❌ `msg.value` (always 0)

---

## Common Patterns Library

### Pattern 1: Single Threshold Monitor

**Use Case:** Monitor one metric against a threshold

**When to Use:**
- Simple alerts (gas price, TVL, balance)
- Clear binary condition
- No historical analysis needed

**Template:**

```solidity
contract SingleThresholdTrap is ITrap {
    uint256 public constant THRESHOLD = 1000 * 10**18;
    address public immutable targetContract;
    
    constructor(address _target) {
        targetContract = _target;
    }
    
    function collect() external view override returns (bytes memory) {
        // Read current value
        uint256 value = ITarget(targetContract).getValue();
        return abi.encode(value, block.number, block.timestamp);
    }
    
    function shouldRespond(bytes[] calldata data) 
        external 
        pure 
        override 
        returns (bool, bytes memory) 
    {
        if (data.length == 0 || data[0].length == 0) return (false, bytes(""));
        
        (uint256 value, uint256 blockNum, uint256 timestamp) = abi.decode(
            data[0],
            (uint256, uint256, uint256)
        );
        
        // Simple threshold check
        if (value > THRESHOLD) {
            return (true, abi.encode(value, blockNum, timestamp));
        }
        
        return (false, bytes(""));
    }
}
```

### Pattern 2: Multi-Source Comparison

**Use Case:** Compare the same data from different sources

**When to Use:**
- Oracle deviation detection
- Price manipulation alerts
- Cross-exchange arbitrage monitoring

**Template:**

```solidity
contract MultiSourceTrap is ITrap {
    uint256 public constant DEVIATION_THRESHOLD = 5; // 5%
    address public immutable sourceA;  // e.g., Chainlink
    address public immutable sourceB;  // e.g., Uniswap
    
    constructor(address _sourceA, address _sourceB) {
        sourceA = _sourceA;
        sourceB = _sourceB;
    }
    
    function collect() external view override returns (bytes memory) {
        // Get price from source A
        uint256 priceA = IPriceSource(sourceA).getPrice();
        
        // Get price from source B
        uint256 priceB = IPriceSource(sourceB).getPrice();
        
        return abi.encode(priceA, priceB, block.timestamp);
    }
    
    function shouldRespond(bytes[] calldata data) 
        external 
        pure 
        override 
        returns (bool, bytes memory) 
    {
        if (data.length == 0 || data[0].length == 0) return (false, bytes(""));
        
        (uint256 priceA, uint256 priceB, uint256 timestamp) = abi.decode(
            data[0],
            (uint256, uint256, uint256)
        );
        
        // Calculate deviation
        uint256 diff = priceA > priceB 
            ? priceA - priceB 
            : priceB - priceA;
        uint256 deviationPercent = (diff * 100) / priceA;
        
        // Trigger if deviation exceeds threshold
        if (deviationPercent >= DEVIATION_THRESHOLD) {
            return (true, abi.encode(priceA, priceB, deviationPercent, timestamp));
        }
        
        return (false, bytes(""));
    }
}
```

### Pattern 3: Time-Series Analysis

**Use Case:** Track changes over multiple blocks

**When to Use:**
- Sustained condition monitoring
- Trend detection
- Gradual attack detection

**Template:**

```solidity
contract TimeSeriesTrap is ITrap {
    uint256 public constant SAMPLE_SIZE = 5;
    uint256 public constant BREACH_THRESHOLD = 3;  // 3 out of 5 blocks
    uint256 public constant VALUE_THRESHOLD = 1000 * 10**18;
    address public immutable targetContract;
    
    constructor(address _target) {
        targetContract = _target;
    }
    
    function collect() external view override returns (bytes memory) {
        uint256 value = ITarget(targetContract).getValue();
        return abi.encode(value, block.number);
    }
    
    function shouldRespond(bytes[] calldata data) 
        external 
        pure 
        override 
        returns (bool, bytes memory) 
    {
        if (data.length == 0 || data[0].length == 0) return (false, bytes(""));
        
        // Count how many samples breach threshold
        uint256 breaches = 0;
        uint256 toCheck = data.length < SAMPLE_SIZE ? data.length : SAMPLE_SIZE;
        
        for (uint256 i = 0; i < toCheck; i++) {
            if (data[i].length == 0) continue;
            
            (uint256 value,) = abi.decode(data[i], (uint256, uint256));
            
            if (value > VALUE_THRESHOLD) {
                breaches++;
            }
        }
        
        // Trigger if sustained breach (e.g., 3 out of 5 blocks)
        if (breaches >= BREACH_THRESHOLD) {
            (uint256 currentValue, uint256 blockNum) = abi.decode(
                data[0],
                (uint256, uint256)
            );
            return (true, abi.encode(currentValue, breaches, blockNum));
        }
        
        return (false, bytes(""));
    }
}
```

**TOML for time-series:**
```toml
block_sample_size = 5  # Must match SAMPLE_SIZE in contract
```

### Pattern 4: Flexible Multi-Vector

**Use Case:** Monitor multiple conditions with flexible triggering

**When to Use:**
- Complex attack detection
- Multiple risk factors
- Resilient to single data source failure

**Template:**

```solidity
contract MultiVectorTrap is ITrap {
    uint256 public constant PRICE_DEVIATION_THRESHOLD = 5;  // 5%
    uint256 public constant VOLUME_THRESHOLD = 1000000 * 10**18;
    uint256 public constant EXTREME_DEVIATION = 10;  // 10%
    
    address public immutable priceOracle;
    address public immutable dexPool;
    
    constructor(address _oracle, address _dex) {
        priceOracle = _oracle;
        dexPool = _dex;
    }
    
    function collect() external view override returns (bytes memory) {
        uint256 oraclePrice = IPriceOracle(priceOracle).getPrice();
        uint256 dexPrice = IDexPool(dexPool).getPrice();
        uint256 volume = IDexPool(dexPool).getVolume();
        
        return abi.encode(oraclePrice, dexPrice, volume, block.timestamp);
    }
    
    function shouldRespond(bytes[] calldata data) 
        external 
        pure 
        override 
        returns (bool, bytes memory) 
    {
        if (data.length == 0 || data[0].length == 0) return (false, bytes(""));
        
        (
            uint256 oraclePrice,
            uint256 dexPrice,
            uint256 volume,
            uint256 timestamp
        ) = abi.decode(data[0], (uint256, uint256, uint256, uint256));
        
        // Calculate deviation
        uint256 diff = oraclePrice > dexPrice 
            ? oraclePrice - dexPrice 
            : dexPrice - oraclePrice;
        uint256 deviation = (diff * 100) / oraclePrice;
        
        // Check each condition independently
        bool condition1 = deviation >= PRICE_DEVIATION_THRESHOLD;
        bool condition2 = volume >= VOLUME_THRESHOLD;
        bool condition3 = deviation >= EXTREME_DEVIATION;
        
        // Count met conditions
        uint8 metConditions = 0;
        if (condition1) metConditions++;
        if (condition2) metConditions++;
        if (condition3) metConditions++;
        
        // Flexible threshold: Trigger if ANY 2 of 3 conditions met
        if (metConditions >= 2) {
            return (
                true,
                abi.encode(oraclePrice, dexPrice, volume, deviation, metConditions, timestamp)
            );
        }
        
        return (false, bytes(""));
    }
}
```

**Why This Works:**
- Triggers if: (condition1 AND condition2) OR (condition1 AND condition3) OR (condition2 AND condition3)
- Resilient to single data source failure
- Reduces false negatives
- Still requires multiple confirmations (low noise)

---

## Debugging Workflow

### Step-by-Step Debugging Process

When your trap isn't working, follow these steps in order:

#### Step 1: Verify Compilation

```bash
cd ~/{your-folder-name}
forge build
```

**Expected:** `Compiler run successful!`

**If fails:** See [Troubleshooting: Compilation Errors](#1-compilation-errors)

**Verify artifacts exist:**
```bash
ls out/YourTrap.sol/YourTrap.json
ls out/YourResponse.sol/YourResponse.json
```

#### Step 2: Verify Response Deployment

```bash
# Check deployment broadcast
ls broadcast/Deploy.sol/

# Verify contract at address
cast code YOUR_RESPONSE_ADDRESS --rpc-url $RPC_URL
```

**Expected:** Long hex string (bytecode)

**If `0x`:** Contract not deployed. Redeploy:
```bash
source .env
forge script script/Deploy.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
```

#### Step 3: Verify ABI Compatibility

**Check trap return:**
```bash
grep "abi.encode" src/YourTrap.sol | head -5
```

**Check response function:**
```bash
grep "function" src/YourResponse.sol
```

**Check TOML:**
```bash
grep "response_function" drosera.toml
```

**All three MUST match!**

Example:
- Trap: `abi.encode(uint256, uint256, uint256)`
- Response: `function handle(uint256 a, uint256 b, uint256 c)`
- TOML: `response_function = "handle(uint256,uint256,uint256)"`

#### Step 4: Test Configuration

```bash
drosera dryrun
```

**Expected:** `✓ Configuration valid`

**If fails:** See specific error in [Troubleshooting](#troubleshooting)

Common issues:
- Response contract not found
- Function selector mismatch
- Invalid artifact path

#### Step 5: Deploy Trap

```bash
source .env
DROSERA_PRIVATE_KEY=$PRIVATE_KEY drosera apply
```

**Expected:** `✓ Trap deployed at: 0x...`

**Verify address added to TOML:**
```bash
cat drosera.toml | grep "address ="
```

#### Step 6: Authorize Operator

```bash
# Get operator address
drosera operator info

# Authorize in Response contract
cast send YOUR_RESPONSE_ADDRESS \
  "setOperator(address,bool)" \
  YOUR_OPERATOR_ADDRESS \
  true \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY

# Verify
cast call YOUR_RESPONSE_ADDRESS \
  "authorizedOperators(address)(bool)" \
  YOUR_OPERATOR_ADDRESS \
  --rpc-url $RPC_URL
```

**Expected:** `true`

#### Step 7: Monitor Dashboard

Wait 1-5 minutes, then:
- Check dashboard for trap listing
- Look for green blocks
- Check operator logs

```bash
journalctl -u drosera-operator -f
```

**Look for:**
- "Executing trap: your_trap_name"
- "Trap result: false" (good - no threat)
- Any error messages

#### Step 8: Test Trigger (Hoodi Only)

If using MockTarget on Hoodi:

```bash
# Trigger condition
cast send YOUR_MOCKTARGET_ADDRESS \
  "setCondition(bool)" \
  true \
  --rpc-url https://rpc.hoodi.ethpandaops.io \
  --private-key $PRIVATE_KEY

# Wait for next execution (check cooldown_period_blocks)
# Should see red block in dashboard

# Reset
cast send YOUR_MOCKTARGET_ADDRESS \
  "setCondition(bool)" \
  false \
  --rpc-url https://rpc.hoodi.ethpandaops.io \
  --private-key $PRIVATE_KEY
```

### Quick Diagnostic Commands

**All-in-one health check:**
```bash
echo "=== HEALTH CHECK ==="
echo ""
echo "1. Operator Status:"
systemctl status drosera-operator | grep "Active:"
echo ""
echo "2. Response Contract:"
cast code $RESPONSE_ADDRESS --rpc-url $RPC_URL | head -c 20
echo "..."
echo ""
echo "3. TOML Trap Address:"
grep "address =" drosera.toml | tail -1
echo ""
echo "4. Operator Authorization:"
cast call $RESPONSE_ADDRESS "authorizedOperators(address)(bool)" $OPERATOR_ADDRESS --rpc-url $RPC_URL
echo ""
echo "5. Recent Operator Logs:"
journalctl -u drosera-operator -n 5 --no-pager
```

---

## Trap Quality Standards

### The Silent Watchdog Pattern

**Core Principle:** Your trap should return `false` 99.9%+ of the time, only triggering on genuine anomalies.

**Why This Matters:**
- Operators run your trap every cooldown period
- Constant triggering wastes gas
- False alarms create noise
- Network sustainability depends on efficient traps

**Examples:**

**✅ Silent Watchdog (Good):**
```solidity
// Only triggers when oracle is stale (rare event)
if (timeSinceUpdate > 3600) {  // 1 hour
    return (true, ...);
}
return (false, bytes(""));
```

**❌ Noisy Trap (Bad):**
```solidity
// Triggers every block when gas > 20 gwei (very common)
if (block.basefee > 20 gwei) {  // Happens constantly!
    return (true, ...);
}
return (false, bytes(""));
```

### Flexible Threshold Logic

For traps with 3+ conditions, implement flexible triggering to reduce false negatives while maintaining low noise.

**2-Vector Traps:** Both conditions required (AND logic)
```solidity
if (condition1 && condition2) {
    return (true, ...);
}
```

**3-Vector Traps:** ANY 2 of 3 conditions (flexible)
```solidity
uint8 met = 0;
if (condition1) met++;
if (condition2) met++;
if (condition3) met++;

if (met >= 2) {  // 2 out of 3
    return (true, ...);
}
```

**4-Vector Traps:** ANY 3 of 4 conditions
```solidity
uint8 met = 0;
if (condition1) met++;
if (condition2) met++;
if (condition3) met++;
if (condition4) met++;

if (met >= 3) {  // 3 out of 4
    return (true, ...);
}
```

**Benefits:**
- ✅ Catches threats even if one data source fails
- ✅ Reduces false negatives
- ✅ Still requires multiple confirmations (low noise)
- ✅ More resilient to oracle issues

### Use Basis Points (BPS) for Precision

**❌ Don't use percentages:**
```solidity
uint256 threshold = 5;  // Is this 5% or 0.05%?
```

**✅ Use basis points (1 BPS = 0.01%):**
```solidity
uint256 THRESHOLD_BPS = 500;  // 5.00% (500/10000)

uint256 deviation = (diff * 10000) / baseValue;
if (deviation >= THRESHOLD_BPS) {
    // 5% deviation detected
}
```

### Avoid tx.gasprice in collect()

**Remember:** `collect()` runs via `eth_call`, not a real transaction.

**❌ Don't use:**
```solidity
uint256 gasPrice = tx.gasprice;  // Often 0 in eth_call
```

**✅ Use instead:**
```solidity
uint256 baseFee = block.basefee;  // Reliable

// Or pass gas price via calldata tail if needed
if (msg.data.length >= 4 + 32) {
    (uint256 gasPrice) = abi.decode(msg.data[4:], (uint256));
}
```

### Gas Optimization

**Prefer constants over storage:**
```solidity
// ✅ Good - No storage slot used
uint256 public constant THRESHOLD = 1000;

// ❌ Bad - Uses storage slot
uint256 public threshold = 1000;
```

**Use immutable for constructor params:**
```solidity
// ✅ Good - Set once, embedded in bytecode
address public immutable targetContract;

constructor(address _target) {
    targetContract = _target;
}
```

**Minimize external calls in collect():**
```solidity
// ✅ Good - Single call
uint256 value = ITarget(target).getValue();

// ❌ Bad - Multiple calls
uint256 value1 = ITarget(target).getValue1();
uint256 value2 = ITarget(target).getValue2();
uint256 value3 = ITarget(target).getValue3();
// Consider: Can target contract provide all values in one call?
```

---

## Examples: Good vs Bad Traps

### ❌ Bad Example: Always-Respond Trap

```solidity
contract AlwaysTrueTrap is ITrap {
    function collect() external view returns (bytes memory) {
        return abi.encode(block.number, block.timestamp);
    }
    
    function shouldRespond(bytes[] calldata data) 
        external 
        pure 
        returns (bool, bytes memory) 
    {
        // ❌ ALWAYS returns true - triggers every cooldown period!
        return (true, data[0]);
    }
}
```

**Problems:**
- Triggers every 33 blocks (Hoodi) or 100 blocks (Mainnet)
- Wastes operator gas constantly
- Provides zero monitoring value
- Adds noise to network

### ❌ Bad Example: Generic Gas Monitor

```solidity
contract BadGasTrap is ITrap {
    uint256 public constant GAS_THRESHOLD = 20 gwei;
    
    function collect() external view returns (bytes memory) {
        return abi.encode(block.basefee);
    }
    
    function shouldRespond(bytes[] calldata data) 
        external 
        pure 
        returns (bool, bytes memory) 
    {
        if (data.length == 0 || data[0].length == 0) return (false, bytes(""));
        
        (uint256 baseFee) = abi.decode(data[0], (uint256));
        
        // ❌ Triggers whenever gas > 20 gwei (very common)
        if (baseFee > GAS_THRESHOLD) {
            return (true, abi.encode(baseFee));
        }
        
        return (false, bytes(""));
    }
}
```

**Problems:**
- 20 gwei is exceeded frequently during normal usage
- No context (why does high gas matter here?)
- Not monitoring any specific vulnerability
- Pure noise

### ✅ Good Example: Hoodi MockTarget Pattern

```solidity
// MockTarget.sol - Simulates vulnerable protocol
contract MockLiquidityPool {
    uint256 public liquidityUSD = 10000000 * 10**18;  // $10M
    address public owner;
    
    event LiquidityChanged(uint256 newLiquidity);
    
    constructor() {
        owner = msg.sender;
    }
    
    function setLiquidity(uint256 _newLiquidity) external {
        require(msg.sender == owner, "Not owner");
        liquidityUSD = _newLiquidity;
        emit LiquidityChanged(_newLiquidity);
    }
    
    function simulateDrain(uint256 percentDrop) external {
        require(msg.sender == owner, "Not owner");
        require(percentDrop <= 100, "Invalid percent");
        liquidityUSD = liquidityUSD * (100 - percentDrop) / 100;
        emit LiquidityChanged(liquidityUSD);
    }
}

// Trap.sol - Monitors for liquidity drain
contract LiquidityDrainTrap is ITrap {
    address public immutable mockPool;
    uint256 public constant BASELINE_LIQUIDITY = 10000000 * 10**18;
    uint256 public constant DRAIN_THRESHOLD_BPS = 3000;  // 30%
    
    constructor(address _mockPool) {
        mockPool = _mockPool;
    }
    
    function collect() external view override returns (bytes memory) {
        uint256 currentLiquidity = IMockPool(mockPool).liquidityUSD();
        return abi.encode(currentLiquidity, block.number, block.timestamp);
    }
    
    function shouldRespond(bytes[] calldata data) 
        external 
        pure 
        override 
        returns (bool, bytes memory) 
    {
        if (data.length == 0 || data[0].length == 0) return (false, bytes(""));
        
        (uint256 currentLiquidity, uint256 blockNum, uint256 timestamp) = abi.decode(
            data[0],
            (uint256, uint256, uint256)
        );
        
        // Calculate drop from baseline
        if (currentLiquidity >= BASELINE_LIQUIDITY) {
            return (false, bytes(""));  // Liquidity increased or stable
        }
        
        uint256 drop = BASELINE_LIQUIDITY - currentLiquidity;
        uint256 dropBPS = (drop * 10000) / BASELINE_LIQUIDITY;
        
        // Trigger if >30% drain
        if (dropBPS >= DRAIN_THRESHOLD_BPS) {
            return (
                true,
                abi.encode(currentLiquidity, BASELINE_LIQUIDITY, dropBPS, blockNum, timestamp)
            );
        }
        
        return (false, bytes(""));
    }
}

// Response.sol
contract LiquidityDrainResponse {
    address public owner;
    mapping(address => bool) public authorizedOperators;
    
    event LiquidityDrainDetected(
        uint256 currentLiquidity,
        uint256 baselineLiquidity,
        uint256 dropBPS,
        uint256 blockNumber,
        uint256 timestamp
    );
    
    constructor() {
        owner = msg.sender;
        authorizedOperators[msg.sender] = true;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    modifier onlyOperator() {
        require(authorizedOperators[msg.sender], "Not authorized");
        _;
    }
    
    function setOperator(address operator, bool authorized) external onlyOwner {
        authorizedOperators[operator] = authorized;
    }
    
    function handleDrain(bytes calldata payload) external onlyOperator {
        (
            uint256 currentLiquidity,
            uint256 baselineLiquidity,
            uint256 dropBPS,
            uint256 blockNumber,
            uint256 timestamp
        ) = abi.decode(payload, (uint256, uint256, uint256, uint256, uint256));
        
        emit LiquidityDrainDetected(
            currentLiquidity,
            baselineLiquidity,
            dropBPS,
            blockNumber,
            timestamp
        );
    }
}
```

**How to Test:**
```bash
# 1. Deploy contracts
forge script script/Deploy.sol --rpc-url https://rpc.hoodi.ethpandaops.io --broadcast --private-key $PRIVATE_KEY

# 2. Configure drosera.toml and deploy trap
DROSERA_PRIVATE_KEY=$PRIVATE_KEY drosera apply

# 3. Trigger 30% drain
cast send MOCK_POOL_ADDRESS \
  "simulateDrain(uint256)" \
  30 \
  --rpc-url https://rpc.hoodi.ethpandaops.io \
  --private-key $PRIVATE_KEY

# 4. Wait for next trap execution
# Should see red block in dashboard

# 5. Reset
cast send MOCK_POOL_ADDRESS \
  "setLiquidity(uint256)" \
  10000000000000000000000000 \
  --rpc-url https://rpc.hoodi.ethpandaops.io \
  --private-key $PRIVATE_KEY
```

### ✅ Good Example: Mainnet Oracle Staleness

```solidity
interface AggregatorV3Interface {
    function latestRoundData() external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );
}

contract OracleStalenessT rap is ITrap {
    AggregatorV3Interface public immutable priceFeed;
    uint256 public constant STALENESS_THRESHOLD = 3600;  // 1 hour
    
    constructor(address _priceFeed) {
        require(_priceFeed != address(0), "Invalid feed");
        priceFeed = AggregatorV3Interface(_priceFeed);
    }
    
    function collect() external view override returns (bytes memory) {
        (
            uint80 roundId,
            int256 answer,
            ,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        
        return abi.encode(
            roundId,
            answer,
            updatedAt,
            answeredInRound,
            block.timestamp
        );
    }
    
    function shouldRespond(bytes[] calldata data) 
        external 
        pure 
        override 
        returns (bool, bytes memory) 
    {
        if (data.length == 0 || data[0].length == 0) return (false, bytes(""));
        
        (
            uint80 roundId,
            int256 answer,
            uint256 updatedAt,
            uint80 answeredInRound,
            uint256 currentTime
        ) = abi.decode(data[0], (uint80, int256, uint256, uint80, uint256));
        
        // Check staleness
        uint256 timeSinceUpdate = currentTime - updatedAt;
        
        // Check round validity
        bool invalidRound = answeredInRound < roundId;
        
        // Trigger if stale OR invalid
        if (timeSinceUpdate > STALENESS_THRESHOLD || invalidRound) {
            return (
                true,
                abi.encode(roundId, answer, updatedAt, timeSinceUpdate, invalidRound)
            );
        }
        
        return (false, bytes(""));
    }
}
```

**Why This Is Good:**
- Monitors critical infrastructure (oracle)
- Clear threshold (1 hour staleness)
- Detects real vulnerability (stale price feeds can enable attacks)
- Silent by default (only triggers when oracle actually stale)
- Includes round validation check
- Historical precedent: Multiple DeFi exploits used stale oracle data

---

## Advanced Topics

### Using Historical Data Effectively

**When block_sample_size > 1**, you have access to historical data in `shouldRespond()`.

**Data Array Structure:**
```
data[0] = Newest block (current)
data[1] = Previous block
data[2] = 2 blocks ago
...
data[N-1] = Oldest block in window
```

**Pattern: Detect Sustained Conditions**

```solidity
uint256 constant SAMPLE_SIZE = 10;
uint256 constant BREACH_COUNT = 7;  // 7 out of 10 blocks

function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
    if (data.length == 0 || data[0].length == 0) return (false, bytes(""));
    
    uint256 breaches = 0;
    uint256 toCheck = data.length < SAMPLE_SIZE ? data.length : SAMPLE_SIZE;
    
    for (uint256 i = 0; i < toCheck; i++) {
        if (data[i].length == 0) continue;
        
        (uint256 value) = abi.decode(data[i], (uint256));
        
        if (value > THRESHOLD) {
            breaches++;
        }
    }
    
    // Trigger if sustained breach (7 out of 10 blocks)
    if (breaches >= BREACH_COUNT) {
        (uint256 currentValue) = abi.decode(data[0], (uint256));
        return (true, abi.encode(currentValue, breaches));
    }
    
    return (false, bytes(""));
}
```

### Passing Off-Chain Data via Calldata Tail

**Problem:** You need data that's not available on-chain (API data, observed transaction gas price, etc.)

**Solution:** Operators can append data to the `collect()` calldata.

```solidity
function collect() external view returns (bytes memory) {
    uint256 observedGasPrice = 0;
    
    // Check if operator appended gas price data
    // Standard function selector is 4 bytes
    // uint256 is 32 bytes
    if (msg.data.length >= 4 + 32) {
        // Decode from position 4 onward (after selector)
        (observedGasPrice) = abi.decode(msg.data[4:], (uint256));
    }
    
    uint256 baseFee = block.basefee;
    uint256 ratio = baseFee == 0 ? 0 : (observedGasPrice * 1e18) / baseFee;
    
    return abi.encode(baseFee, observedGasPrice, ratio, block.number);
}
```

**How Operator Calls:**
```bash
# Operator observes gas price of 50 gwei from mempool
# Appends it to collect() call
cast call TRAP_ADDRESS \
  "collect()(bytes)" \
  --calldata "0x2986c0e5" + abi.encode(uint256(50 * 10**9)) \
  --rpc-url $RPC_URL
```

### Multi-Block Pattern Detection

**Use Case:** Detect patterns across multiple blocks (e.g., gradual drain, coordinated attack)

```solidity
uint256 constant SAMPLE_SIZE = 5;

function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
    if (data.length < 2) return (false, bytes(""));  // Need at least 2 samples
    
    // Compare newest to oldest in window
    uint256 toCheck = data.length < SAMPLE_SIZE ? data.length : SAMPLE_SIZE;
    
    (uint256 newestValue) = abi.decode(data[0], (uint256));
    (uint256 oldestValue) = abi.decode(data[toCheck - 1], (uint256));
    
    // Calculate change over window
    if (oldestValue == 0) return (false, bytes(""));
    
    uint256 percentChange = oldestValue > newestValue
        ? ((oldestValue - newestValue) * 10000) / oldestValue
        : 0;
    
    // Trigger if >30% drop over window
    if (percentChange >= 3000) {  // 30% in BPS
        return (true, abi.encode(newestValue, oldestValue, percentChange));
    }
    
    return (false, bytes(""));
}
```

### Gas Optimization Techniques

**1. Cache array length:**
```solidity
// ❌ Gas inefficient
for (uint256 i = 0; i < data.length; i++) {
    // data.length read every iteration
}

// ✅ Gas efficient
uint256 len = data.length;
for (uint256 i = 0; i < len; i++) {
    // len read once
}
```

**2. Use unchecked for counters:**
```solidity
// ✅ Gas efficient (counters can't overflow in reasonable loops)
for (uint256 i = 0; i < len;) {
    // ...
    unchecked { ++i; }  // Save gas on overflow check
}
```

**3. Pack multiple conditions:**
```solidity
// ❌ Multiple comparisons
bool cond1 = value > threshold1;
bool cond2 = value > threshold2;
bool cond3 = value > threshold3;

// ✅ Single comparison with bitwise packing
uint8 conditions = 0;
if (value > threshold1) conditions |= 1;
if (value > threshold2) conditions |= 2;
if (value > threshold3) conditions |= 4;
```

**4. Early returns:**
```solidity
// ✅ Return early to save gas
function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
    if (data.length == 0 || data[0].length == 0) {
        return (false, bytes(""));  // Early return
    }
    
    (uint256 value) = abi.decode(data[0], (uint256));
    
    if (value == 0) {
        return (false, bytes(""));  // Early return
    }
    
    // Complex logic only if we passed early checks
    // ...
}
```

### Event Emission Best Practices

**In Response Contract:**

```solidity
event AlertTriggered(
    uint256 indexed value,  // Indexed for filtering
    uint256 blockNumber,
    uint256 timestamp,
    address indexed caller,
    bytes32 alertType
);

function handleAlert(bytes calldata payload) external onlyOperator {
    (uint256 value, uint256 blockNum, uint256 timestamp) = abi.decode(
        payload,
        (uint256, uint256, uint256)
    );
    
    emit AlertTriggered(
        value,
        blockNum,
        timestamp,
        msg.sender,
        keccak256("PRICE_DEVIATION")
    );
}
```

**Benefits:**
- Indexed fields allow efficient filtering
- All context included in event
- Easy to track via subgraphs or APIs

---

## Additional Resources

- **[Drosera Documentation](https://docs.drosera.io)** - Official network docs
- **[Drosera Discord](https://discord.gg/drosera)** - Community support
- **[Foundry Book](https://book.getfoundry.sh)** - Smart contract development
- **[Solidity Documentation](https://docs.soliditylang.org)** - Language reference
- **[Cast Documentation](https://book.getfoundry.sh/cast/)** - Command-line tools

---

**[← Back to Quick Start](README.md)**
