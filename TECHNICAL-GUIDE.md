# Complete Technical Guide

**[← Back to Quick Start](README.md)**

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Phase 1: Local Development](#phase-1-local-development)
3. [Phase 2: Drosera Integration](#phase-2-drosera-integration)
4. [Phase 3: Operator Setup (Optional)](#phase-3-operator-setup-optional)
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
# Update system dependencies
apt-get update && apt-get install git curl unzip screen -y

# Install Foundry (if not already installed)
curl -L [https://foundry.paradigm.xyz](https://foundry.paradigm.xyz) | bash
source ~/.bashrc && foundryup

# Initialize clean workspace
forge init {folder-name}
cd {folder-name}

# Cleanup default examples
rm src/Counter.sol script/Counter.s.sol test/Counter.t.sol
```

**What this does:**
- Installs necessary system dependencies and Foundry
- Initializes a clean Foundry project
- Removes default template files to prepare for your custom trap

**Verify setup:**
```bash
pwd
ls src/
```

Expected:
- Directory: `/home/your-username/{folder-name}`
- `src/` should be empty

</details>

---

<details>
<summary>Step 3: Install Drosera Dependencies</summary>

We need the official Drosera smart contracts and Forge Standard Library:

```bash
forge install drosera-network/contracts foundry-rs/forge-std
```

Map the dependencies correctly and create a script folder:

```bash
echo "drosera-contracts/=lib/contracts/src/" > remappings.txt && echo "forge-std/=lib/forge-std/src/" >> remappings.txt && mkdir -p script
```

**(Optional) Install OpenZeppelin if needed for your trap logic:**
```bash
forge install OpenZeppelin/openzeppelin-contracts@v5.0.2
```

**Verify ITrap interface is available:**
```bash
ls lib/contracts/src/interfaces/ITrap.sol
```

**The ITrap interface signature (for reference):**

```solidity
interface ITrap {
    function collect() external view returns (bytes memory);
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory);
}
```

> **⚠️ CRITICAL:** Note that `shouldRespond` takes `bytes[]` (array), NOT `bytes` (singular). This is non-negotiable for Drosera compatibility.

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

```solidity
import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

contract YourTrap is ITrap {
    // Your trap implementation
}
```

- `collect()`: Gathers monitoring data from blockchain/contracts
- `shouldRespond()`: Evaluates if trigger conditions are met

**CRITICAL REQUIREMENTS:**

**Interface Compliance:**
- `collect()` MUST be `view` (not `pure`)
- `shouldRespond()` MUST be `pure` (not `view`)
- `shouldRespond` MUST take `bytes[]` calldata (not `bytes`)
- Must include `override` keywords
- Must `import` and `is ITrap`

**Data Handling:**
- `data[0]` contains the **newest** block data (Drosera ordering)
- **ALWAYS** check `if (data.length == 0 || data[0].length == 0)` before decoding
- For fixed-size data, check exact length: `if (data[0].length != 32)` for single uint256
- Return `bytes("")` for empty returns (not `""`)

**Stateless Trap Requirements (CRITICAL - Read Carefully):**
- **NO storage variables** - Drosera redeploys trap on shadow-fork EVERY block
- **NO constructor arguments** - Constructor must take zero parameters
- **State does NOT persist** between blocks - All storage resets to defaults (0, false, address(0))
- Use `constant` or `immutable` ONLY for fixed values that don't change
- ❌ **WRONG:** `uint256 public lastPrice;` - This will ALWAYS be 0
- ❌ **WRONG:** `bool public crashDetected;` - This will ALWAYS be false
- ❌ **WRONG:** Helper functions that mutate state - They are NEVER called on shadow-fork
- ✅ **CORRECT:** Read external contract state in `collect()` using view calls

**Why This Matters:**
Drosera deploys a fresh trap instance on shadow-fork every block. Your trap's flow is:
1. Deploy fresh (constructor with no args)
2. Call `collect()` (view)
3. Call `shouldRespond()` (pure)
4. Discard instance

Any storage you write is lost immediately.

**ABI Wiring (CRITICAL - Most Common Failure):**

The bytes returned by `shouldRespond()` MUST exactly match your `response_function` signature in `drosera.toml`.

**Correct Pattern:**
```solidity
// Trap returns:
return (true, abi.encode(gasPrice, timestamp));

// Response function:
function handleAlert(uint256 gasPrice, uint256 timestamp) external onlyOperator {
    emit AlertTriggered(gasPrice, timestamp);
}

// drosera.toml:
response_function = "handleAlert(uint256,uint256)"
```

**Common Mistakes:**
- ❌ Trap returns `bytes("alert")` but responder expects `string` → Must use `abi.encode("alert")`
- ❌ Trap returns `abi.encode(value)` but TOML says `respond(bytes[])` → Type mismatch
- ❌ Trap returns 2 values but responder only accepts 1 → Decoding fails

**Save with:** `Ctrl+X`, `Y`, `Enter`

---

#### 2. Response Contract (`src/{TrapName}Response.sol`):

```bash
nano src/{YourTrapName}Response.sol
```

Contains the action to execute when trap triggers.

> **⚠️ CRITICAL AUTHORIZATION WARNING (60% of users get this wrong):**
> - **DO NOT** use `require(msg.sender == address(trap))` or `onlyTrap()` modifier
> - The Trap contract does NOT call your Response function
> - The Drosera Operator/Executor EOA calls it directly
> - `msg.sender` will be the operator address, NOT the trap contract
> - Correct pattern: Use operator-based authorization

**Example of CORRECT authorization:**

```solidity
address public owner;
mapping(address => bool) public authorizedOperators;

constructor() {
    owner = msg.sender;
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
    emit AlertTriggered(payload);
}
```

**Example of WRONG authorization (will always revert):**

```solidity
// ❌ BAD - This will ALWAYS revert because msg.sender is the operator, not the trap
address public trapAddress;
mapping(address => bool) public authorizedTraps;

modifier onlyTrap() {
    require(msg.sender == trapAddress, "Only trap");
    // OR
    require(authorizedTraps[msg.sender], "Only trap");
    _;
}
```

**Why This Fails:**
Drosera's execution flow is: Operator → Response Contract (direct call)
NOT: Operator → Trap → Response Contract

**Save with:** `Ctrl+X`, `Y`, `Enter`

---

#### 3. Deploy Script (`script/Deploy.sol`):

```bash
nano script/Deploy.sol
```

**Deploy all on-chain dependencies:**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/YourResponse.sol";
// Import any mock contracts needed for testing
// import "../src/MockOracle.sol";
// import "../src/MockVault.sol";

contract DeployScript is Script {
    function run() external {
        vm.startBroadcast();
        
        // 1. Deploy any mock contracts first (for Hoodi testing)
        // MockOracle oracle = new MockOracle();
        // console.log("Mock Oracle deployed at:", address(oracle));
        
        // 2. Deploy the Response contract
        YourResponse response = new YourResponse();
        console.log("Response deployed at:", address(response));

        // 3. STOP HERE - Do NOT deploy the Trap Contract
        // Drosera reads the Trap logic from compiled JSON artifact
        // Deploying it yourself creates address conflicts
        
        vm.stopBroadcast();
    }
}
```

**Important Notes:**
- **DO** deploy: Response contract, any mock contracts (oracles, vaults, etc.) needed for testing
- **DO NOT** deploy: The Trap contract itself
- Drosera operators read trap bytecode from your `out/{TrapName}.sol/{TrapName}.json` artifact
- Drosera deploys trap instances on shadow-fork during execution

**Save with:** `Ctrl+X`, `Y`, `Enter`

</details>

---

<details>
<summary>Step 5: Setup Environment</summary>

**Create .env:**
```bash
nano .env
```

```env
PRIVATE_KEY=0xYOUR_PRIVATE_KEY_HERE
```

**Save with:** `Ctrl+X`, `Y`, `Enter`

**Secure and load:**
```bash
chmod 600 .env
source .env
```

</details>

---

<details>
<summary>Step 6: Compile</summary>

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

**Verify artifacts:**
```bash
ls out/{TrapName}Trap.sol/{TrapName}Trap.json
ls out/{TrapName}Response.sol/{TrapName}Response.json
```

</details>

---

<details>
<summary>Step 7: Deploy Response Contract & Dependencies</summary>

**For Hoodi Testnet:**
```bash
source .env
forge script script/Deploy.sol \
  --rpc-url [https://rpc.hoodi.ethpandaops.io](https://rpc.hoodi.ethpandaops.io) \
  --private-key $PRIVATE_KEY \
  --broadcast
```

**For Ethereum Mainnet:**
```bash
source .env
forge script script/Deploy.sol \
  --rpc-url [https://eth.llamarpc.com](https://eth.llamarpc.com) \
  --private-key $PRIVATE_KEY \
  --broadcast
```

**What gets deployed:**
- Response contract (required)
- Any mock contracts (oracles, vaults, etc.) if your trap needs them for testing
- Any other on-chain dependencies your trap requires

**Important:** The Trap contract itself is NOT deployed - Drosera deploys it automatically via `drosera apply`.

**Save your Response contract address from the output!**

Expected output:
```
Response deployed at: 0xYourResponseAddress
```

Copy this address - you'll need it for `drosera.toml` in Phase 2.

</details>

---

## Phase 2: Drosera Integration

<details>
<summary>Step 1: Create drosera.toml</summary>

**For Hoodi Testnet:**

```toml
ethereum_rpc = "[https://rpc.hoodi.ethpandaops.io/](https://rpc.hoodi.ethpandaops.io/)"
drosera_rpc = "[https://relay.hoodi.drosera.io](https://relay.hoodi.drosera.io)"
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
whitelist = ["0xYOUR_WALLET_ADDRESS"]
private_trap = true

# DO NOT add 'address = ...' - Drosera auto-deploys the Trap
```

**For Ethereum Mainnet:**

```toml
ethereum_rpc = "[https://eth.llamarpc.com](https://eth.llamarpc.com)"
drosera_rpc = "[https://relay.ethereum.drosera.io](https://relay.ethereum.drosera.io)"

[traps]
[traps.your_trap_snake_case]
path = "out/YourTrap.sol/YourTrap.json"
response_contract = "0xYOUR_RESPONSE_ADDRESS"
response_function = "yourFunction(address,uint256)"
cooldown_period_blocks = 100
min_number_of_operators = 2
max_number_of_operators = 5
block_sample_size = 5
whitelist = ["0xYOUR_WALLET_ADDRESS"]
private_trap = true

# DO NOT add 'address = ...' - Drosera auto-deploys the Trap
```

**Key Fields:**

- `response_contract`: Your deployed Response contract address
- `response_function`: Must match your Response contract's function signature exactly
- `whitelist`: Your wallet address that can trigger the trap
- `block_sample_size`: Number of historical blocks to pass to `shouldRespond()`

**block_sample_size Guidelines:**
- **Default to 1** for beginners and simple threshold checks
- **Use 2+** only when your logic needs historical comparison:
  - Detecting price drops over time (compare data[0] vs data[1])
  - Checking for consecutive breaches across multiple blocks
  - Analyzing trends or variance
- **Rule:** If your `shouldRespond()` only checks `data[0]`, set `block_sample_size = 1`
- **Example:** "Trigger if gas > 100 gwei" → Use 1
- **Example:** "Trigger if price dropped >30% in last 5 blocks" → Use 5

**CRITICAL:** Unless you want to update an existing trap that you own, Do Not include an `address` field. otherwise this will cause error when you run `drosera apply`

</details>

---

<details>
<summary>Step 2: Test Configuration</summary>

```bash
drosera dryrun
```

This validates your trap logic without deploying. If successful, proceed to apply.

</details>

---

<details>
<summary>Step 3: Deploy to Drosera Network</summary>

**Load environment variables:**
```bash
source .env
```

**Deploy trap configuration:**
```bash
DROSERA_PRIVATE_KEY=$PRIVATE_KEY drosera apply
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

</details>

---

## Phase 3: Operator Setup (Optional)

<details>
<summary>Step 1: Create Drosera Network Folder</summary>

**Navigate to root directory and create folder:**
```bash
cd ~
mkdir ~/Drosera-Network
cd ~/Drosera-Network
```

</details>

---

<details>
<summary>Step 2: Install Operator CLI</summary>

The operator CLI is needed for registration and opt-in commands. This script automatically detects your system architecture and installs the latest version:

```bash
# Detect latest version
LATEST=$(curl -s [https://api.github.com/repos/drosera-network/releases/releases/latest](https://api.github.com/repos/drosera-network/releases/releases/latest) | grep tag_name | cut -d '"' -f 4)

# Detect system architecture
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
  TARGET="x86_64-unknown-linux-gnu"
elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
  TARGET="aarch64-unknown-linux-gnu"
else
  echo "Unsupported architecture: $ARCH"
  exit 1
fi

# Download operator CLI
curl -LO "[https://github.com/drosera-network/releases/releases/download/$](https://github.com/drosera-network/releases/releases/download/$){LATEST}/drosera-operator-${LATEST}-${TARGET}.tar.gz"

# Extract
tar -xvf drosera-operator-${LATEST}-${TARGET}.tar.gz
chmod +x drosera-operator

# Install (sudo-safe)
if command -v sudo >/dev/null 2>&1; then
  sudo cp drosera-operator /usr/bin/
else
  mkdir -p $HOME/.local/bin
  cp drosera-operator $HOME/.local/bin/
  export PATH="$HOME/.local/bin:$PATH"
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

# Verify installation
drosera-operator --version
```

**Expected output:** Version number (e.g., `drosera-operator 1.23.1`)

**What this does:**
- ✅ Auto-detects latest version (future-proof)
- ✅ Auto-detects CPU architecture (x86_64 or ARM)
- ✅ Works with or without sudo access
- ✅ Installs globally for easy access

</details>

---

<details>
<summary>Step 3: Create docker-compose.yaml</summary>

```bash
nano docker-compose.yaml
```

**For Hoodi Testnet:**

```yaml
version: '3.8'

services:
  drosera-operator:
    image: ghcr.io/drosera-network/drosera-operator:latest
    container_name: drosera-operator
    ports:
      - "31313:31313"   # P2P
      - "31314:31314"   # HTTP
    environment:
      - DRO__DB_FILE_PATH=/data/drosera.db
      - DRO__DROSERA_ADDRESS=0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D
      - DRO__LISTEN_ADDRESS=0.0.0.0
      - DRO__DISABLE_DNR_CONFIRMATION=true
      - DRO__ETH__CHAIN_ID=560048
      - DRO__ETH__RPC_URL=[https://rpc.hoodi.ethpandaops.io](https://rpc.hoodi.ethpandaops.io)
      - DRO__ETH__BACKUP_RPC_URL=[https://ethereum-hoodi-rpc.publicnode.com](https://ethereum-hoodi-rpc.publicnode.com)
      - DRO__ETH__PRIVATE_KEY=${ETH_PRIVATE_KEY}
      - DRO__NETWORK__P2P_PORT=31313
      - DRO__NETWORK__EXTERNAL_P2P_ADDRESS=${VPS_IP}
      - DRO__SERVER__PORT=31314
      - RUST_LOG=info,drosera_operator=debug
      - DRO__ETH__RPC_TIMEOUT=30s
      - DRO__ETH__RETRY_COUNT=5
    volumes:
      - drosera_data:/data
    restart: always
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "5"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:31314/health"]
      interval: 60s
      timeout: 10s
      retries: 3
      start_period: 30s
    command: node

volumes:
  drosera_data:
```

**For Ethereum Mainnet:**

```yaml
version: '3.8'

services:
  operator1:
    image: ghcr.io/drosera-network/drosera-operator:latest
    network_mode: host
    command: ["node"]
    environment:
      - DRO__ETH__CHAIN_ID=1
      - DRO__ETH__RPC_URL=[https://eth.llamarpc.com](https://eth.llamarpc.com)
      - DRO__ETH__PRIVATE_KEY=${ETH_PRIVATE_KEY}
      - DRO__NETWORK__P2P_PORT=31313
      - DRO__NETWORK__EXTERNAL_P2P_ADDRESS=${VPS_IP}
      - DRO__DISABLE_DNR_CONFIRMATION=true
      - DRO__SERVER__PORT=31314
      - DRO__INSTRUMENTATION__LOG_LEVEL=debug
      - DRO__INSTRUMENTATION__LOG_FORMAT=full
      - DRO__INSTRUMENTATION__LOG_OUT=stdout
    volumes:
      - op1_data:/data
    restart: always

volumes:
  op1_data:
```

> **⚠️ IMPORTANT:** Do NOT put your private key or VPS IP directly in the YAML file. Use environment variables from `.env` file.

**Save with:** `Ctrl+X`, `Y`, `Enter`

</details>

---

<details>
<summary>Step 4: Create .env File</summary>

**Create .env file in the same folder:**
```bash
nano .env
```

**Add your credentials:**
```env
ETH_PRIVATE_KEY=your_eth_private_key_here
VPS_IP=your_vps_public_ip_here
```

**Save with:** `Ctrl+X`, `Y`, `Enter`

**Secure the file:**
```bash
chmod 600 .env
```

</details>

---

<details>
<summary>Step 5: Pull Docker Image</summary>

```bash
docker pull ghcr.io/drosera-network/drosera-operator:latest
```

**Verify image downloaded:**
```bash
docker images | grep drosera-operator
```

</details>

---

<details>
<summary>Step 6: Start Operator Container</summary>

**Stop and remove any existing containers (clean start):**
```bash
docker compose down -v
docker stop drosera-node 2>/dev/null || true
docker rm drosera-node 2>/dev/null || true
```

**Start the operator:**
```bash
docker compose up -d
```

**Check container status:**
```bash
docker ps
```

Expected: Container `drosera-operator` should be running

**View live logs:**
```bash
docker compose logs -f
```

</details>

---

<details>
<summary>Step 7: Register Operator</summary>

**Load environment variables:**
```bash
source .env
```

**For Hoodi Testnet:**
```bash
drosera-operator register \
  --eth-rpc-url [https://rpc.hoodi.ethpandaops.io](https://rpc.hoodi.ethpandaops.io) \
  --eth-private-key $PRIVATE_KEY \
  --drosera-address 0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D
```

**For Ethereum Mainnet:**
```bash
drosera-operator register \
  --eth-rpc-url [https://eth.llamarpc.com](https://eth.llamarpc.com) \
  --eth-private-key $PRIVATE_KEY
```

This registers your BLS public key with the Drosera registry.

</details>

---

<details>
<summary>Step 8: Opt-In Operator to Trap</summary>

**Get your trap address from `drosera.toml`:**
```bash
cat ~/your-trap-folder/drosera.toml | grep "address"
```

**For Hoodi Testnet:**
```bash
drosera-operator optin \
  --eth-rpc-url [https://rpc.hoodi.ethpandaops.io](https://rpc.hoodi.ethpandaops.io) \
  --eth-private-key $PRIVATE_KEY \
  --trap-config-address your_trap_address_here
```

**For Ethereum Mainnet:**
```bash
drosera opt-in \
  --trap-address your_trap_address_here \
  --eth-rpc-url [https://eth.llamarpc.com](https://eth.llamarpc.com) \
  --eth-private-key $PRIVATE_KEY
```

> **Note:** Replace `your_trap_address_here` with the actual trap address. If confused, opt-in from the dashboard.

</details>

---

<details>
<summary>Step 9: Monitor Operator Logs</summary>

**Follow logs in real-time:**
```bash
cd ~/Drosera-Network
docker compose logs -f
```

---

### **Expected Log Patterns:**

**1. Initial Startup:**

```
drosera-operator | INFO drosera_operator::node: Spawning node...
drosera-operator | INFO Trap Attestation Service started
drosera-operator | INFO Operator Node successfully spawned!
drosera-operator | INFO Registered DNR with seed node trap_address=0x...
drosera-operator |  INFO Bootstrapping with seed node...
drosera-operator | INFO Starting trap enzyme runner trap_address=0x... block_number=23960771
```

**What this means:**
- ✅ Operator started successfully
- ✅ Connected to Drosera network
- ✅ Monitoring your trap
- ⚠️ You may see some ERROR/WARN messages during initial sync (like "Batch size too large" or "Block not found") - these are **normal** and will resolve within 1-2 minutes

---

**2. Healthy Operation (Silent Monitoring):**

```
drosera-operator | DEBUG Received new block trap_address=0x6... block_number=2229186
drosera-operator | DEBUG Execution of Trap completed block_number=2229186
drosera-operator | INFO ShouldRespond='false' trap_address=0x6...

[... repeats for each new block ...]
```

**What this means:**
- ✅ Trap is monitoring every new block
- ✅ `ShouldRespond='false'` means **no anomaly detected** - this is the expected state
- ✅ Your trap is working correctly, staying silent until a real threat appears

---

**3. Anomaly Detected & Response Executed:**

```
drosera-operator | INFO ShouldRespond='true' trap_address=0x6... block_number=2229186
drosera-operator | DEBUG Generated attestation to aggregate and gossip
drosera-operator | INFO Reached signature threshold on trap execution result
drosera-operator | INFO Aggregated attestation result is 'shouldRespond=true'
drosera-operator | INFO Cooldown period is active, skipping submission

[...]

drosera-operator | INFO This node is selected to submit the claim
drosera-operator | INFO Response function executed successfully
```

**What this means:**
- 🔍 Conditions your created as "anomaly" were detected and the trap was triggered
- ✅ Operators reached agreement on the detection
- ⏸️ "Cooldown period active" means there was a recent execution, waiting before next response
- **Note:** Frequent triggers may indicate overly sensitive thresholds - review your trap logic

---

### **Common Warnings You Can Ignore:**

```
WARN Failed to gossip message: InsufficientPeers
```
↳ Normal if running single operator

```
ERROR Failed to get block: Batch size too large
```
↳ RPC limitation during initial sync, recovers automatically

```
WARN No result from shouldRespond function
```
↳ During initial sync, resolves within 1-2 minutes

---

**Helpful commands if needed:**
```bash
# Stop operator
docker compose down

# Start operator 
docker compose up -d

# View live logs
docker compose logs -f

# Restart operator 
docker compose restart
```

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

forge build
forge test

## Deployment
See [TECHNICAL-GUIDE.md](TECHNICAL-GUIDE.md) for full deployment instructions.
```

**Save with:** `Ctrl+X`, `Y`, `Enter`

</details>

---

<details>
<summary>Step 3: Create GitHub Repository & Push Code</summary>

**1. Create Personal Access Token (PAT):**

GitHub no longer accepts password authentication. You need a token:

- Go to https://github.com/settings/tokens
- Click **"Generate new token (classic)"**
- Select scopes: `repo` (all)
- Click **"Generate token"**
- **Copy the token** (you won't see it again)

---

**2. Configure Git:**

```bash
git config --global user.email "your_email@example.com"
git config --global user.name "Your Name"
```

---

**3. Create GitHub Repository:**

- Go to https://github.com/new
- **Repository name:** `{your-trap-name}` (match your trap folder name)
- **Visibility:** Public (required for Drosera dashboard)
- **Do NOT** initialize with README (you already have files)
- Click **"Create repository"**

---

**4. Push Your Code:**

```bash
git remote add origin [https://github.com/](https://github.com/){username}/{repo-name}.git
git branch -M main
git push -u origin main
```

When prompted for password, **paste your PAT token** (not your GitHub password).

**Verify:**
Visit `https://github.com/{username}/{repo-name}` - you should see your code.

</details>

---

## Phase 5: Dashboard Verification

<details>
<summary>Step 1: Access Drosera Dashboard</summary>

**Navigate to:** https://app.drosera.io

**Connect wallet** (the one you used to deploy)

**Switch Network** (Hoodi or Mainnet)

</details>

---

<details>
<summary>Step 2: Find Your Trap</summary>

Navigate to **Traps Explorer**

**Search by:**
- Trap address (or config): `0xYourTrapAddress`
- Creator address: `0xYourWalletAddress`
- Operator address: `0xWhitelistedAddresses`

**Verify displayed information:**
- ✅ Response function matches drosera.toml
- ✅ Response contract address correct
- ✅ Liveness data records green blocks

</details>

---

<details>
<summary>Step 3: Send Bloom Boost (Recommended)</summary>

**What is Bloom Boost?**
A gas fund that pays operators for executing your trap's response function on-chain. When your trap triggers, the operator who submits the transaction gets reimbursed for gas costs plus a priority fee.

**How to send:**

1. Open your trap on the dashboard: https://app.drosera.io/trap?trapId=0xYourTrapAddress
2. Click **"Send Bloom Boost"**
3. Send any amount you're comfortable with, depending on expected gas costs and network activity

**Why this matters:**
Without Bloom Boost, operators won't be reimbursed for executing your trap's response, which may cause them to skip monitoring it.

**Check your balance:**
View current Bloom Boost balance on your trap's dashboard page.

</details>

---

## Troubleshooting

### Common Issues and Operator Errors

<details>
<summary>Issue 1: "Execution Reverted" Error During `drosera apply`</summary>

**Cause:** You manually deployed the Trap contract and included its address in `drosera.toml`.

**Solution:**
- Remove the `address = "0x..."` line from your `[traps.your_trap]` section
- Let Drosera deploy the Trap automatically
- Only the `response_contract` field should contain an address you deployed

</details>

---

<details>
<summary>Issue 2: Storage Variables Don't Persist / Trap Never Triggers</summary>

**Problem:** You added storage variables like `uint256 public lastPrice` or `bool crashDetected` and expect them to persist between blocks.

**Why It Fails:**
- Drosera redeploys trap on shadow-fork EVERY block
- All storage resets to defaults: `0`, `false`, `address(0)`
- Helper functions that mutate state are NEVER called on shadow-fork

**Solution:**
- Remove ALL storage variables from trap
- Use external contracts for state (e.g., deploy a MockThreatFeed contract)
- Read state from external contract in `collect()` via view calls
- Only use `constant` or `immutable` for fixed values

**Example WRONG:**
```solidity
uint256 public lastPrice; // Will ALWAYS be 0
bool public triggered; // Will ALWAYS be false
```

**Example CORRECT:**
```solidity
address public immutable feedContract; // Fixed value, OK
uint256 public constant THRESHOLD = 1000; // Fixed value, OK
```

</details>

---

<details>
<summary>Issue 3: Response Function Reverts with "Not Authorized"</summary>

**Problem:** Your response function uses `onlyTrap()` modifier checking `msg.sender == trapAddress`.

**Why It Fails:**
- Drosera operator/executor calls response function directly
- `msg.sender` is the operator EOA, NOT the trap contract
- Your modifier rejects the call

**Solution:**
- Use operator-based authorization instead of trap-based
- See Phase 1, Step 4 for correct authorization pattern
- After deploying, authorize your operator address via `setOperator()`

</details>

---

<details>
<summary>Issue 4: ABI Mismatch - Response Never Executes</summary>

**Problem:** Type mismatch between trap's return value and response function signature.

**Common Mistakes:**
- Trap returns `bytes("alert")` but responder expects `string` → Must use `abi.encode("alert")`
- Trap returns `abi.encode(uint256)` but TOML says `respond(bytes[])` → Type mismatch
- Trap returns 2 values but responder only accepts 1 parameter → Decoding fails
- Response function doesn't exist in deployed contract

**Solution:**
- Ensure trap returns: `abi.encode(param1, param2, ...)`
- Ensure response function: `function respond(type1 param1, type2 param2, ...) external`
- Ensure TOML: `response_function = "respond(type1,type2,...)"`
- All three MUST match EXACTLY

**Example CORRECT:**
```solidity
// Trap:
return (true, abi.encode(gasPrice, timestamp));

// Response:
function handleAlert(uint256 gasPrice, uint256 timestamp) external { ... }

// TOML:
response_function = "handleAlert(uint256,uint256)"
```

</details>

---

<details>
<summary>Issue 5: `drosera dryrun` Succeeds but `apply` Fails</summary>

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

</details>

---

<details>
<summary>Issue 6: Compilation Errors (`forge build` fails)</summary>

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
- Ensure you haven't accidentally modified the imported `ITrap.sol` interface.

</details>

---

<details>
<summary>Issue 7: Trap Not Appearing in Dashboard</summary>

**Check:**
- Operator is running: `docker ps` (check if drosera-operator container is up)
- Correct network selected in dashboard
- `drosera apply` completed successfully
- Wait a few minutes for network propagation

**Solution:**
```bash
# Check operator status
docker ps | grep drosera

# Check operator logs
docker compose logs -f
```

</details>

---

<details>
<summary>Issue 8: Red Blocks in Dashboard (Errors)</summary>

**Causes:**
- `collect()` function reverts (external call fails)
- `shouldRespond()` function has bugs
- Missing safety check: `if (data.length == 0 || data[0].length == 0)` before decoding
- Network connectivity issues

**Solution:**
- Review trap logic for potential revert conditions
- Add defensive checks in `shouldRespond()`
- Test with `drosera dryrun` on current network state
- Check operator logs for specific error messages

</details>

---

<details>
<summary>Operator Error 1: "InsufficientPeers" Warning</summary>

**Error Message:**
```
WARN drosera_services::network::service: Failed to gossip message: InsufficientPeers
```

**Cause:** Your operator doesn't have enough peer connections to gossip messages.

**Is This a Problem?**
- **NO** - If you're running a single operator on your trap
- **YES** - If you're running multiple operators but they can't connect

**Solution:**
- **For single operator:** Ignore this warning, it's normal
- **For multiple operators:**
  - Check firewall rules (ports 31313, 31314 must be open)
  - Verify VPS_IP is correct in `.env`
  - Check both operators are running: `docker ps`
  - Wait 2-3 minutes for peer discovery

</details>

---

<details>
<summary>Operator Error 2: RPC Connection Failed / Timeout</summary>

**Error Messages:**
```
ERROR Failed to call eth_call: request timeout
ERROR RPC connection failed
ERROR Connection refused
```

**Cause:** RPC endpoint is down, rate-limited, or unreachable.

**Solution:**

**Option 1: Use Private RPC (Recommended)**
- Get free RPC from [Alchemy](https://www.alchemy.com/) or [QuickNode](https://www.quicknode.com/)
- Update `DRO__ETH__RPC_URL` in `docker-compose.yaml`
- Restart operator: `docker compose restart`

**Option 2: Add Backup RPC**
Already configured in the docker-compose.yaml:
```yaml
- DRO__ETH__BACKUP_RPC_URL=[https://ethereum-hoodi-rpc.publicnode.com](https://ethereum-hoodi-rpc.publicnode.com)
```

**Option 3: Check RPC Status**
```bash
# Test RPC connection
curl -X POST [https://rpc.hoodi.ethpandaops.io](https://rpc.hoodi.ethpandaops.io) \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
```

</details>

---

<details>
<summary>Operator Error 3: Port Already in Use</summary>

**Error Message:**
```
Error starting userland proxy: listen tcp 0.0.0.0:31313: bind: address already in use
```

**Cause:** Another process is using ports 31313 or 31314.

**Solution:**

**Check what's using the port:**
```bash
sudo lsof -i :31313
sudo lsof -i :31314
```

**Option 1: Stop the conflicting process**
```bash
sudo kill <PID>
```

**Option 2: Use different ports**
Edit `docker-compose.yaml` and change:
```yaml
ports:
  - "31315:31313"  # Changed external port
  - "31316:31314"  # Changed external port
```

Also update `DRO__NETWORK__P2P_PORT` accordingly.

</details>

---

<details>
<summary>Operator Error 4: Port Conflicts Running Both Hoodi and Mainnet</summary>

**Problem:** You want to run operators on both Hoodi testnet and Ethereum mainnet simultaneously on the same machine, but encounter port conflicts.

**Error Messages:**
```
Error starting userland proxy: listen tcp 0.0.0.0:31313: bind: address already in use
```
OR
```
HEARTBEAT: Mesh low. Topic contains: 0 needs: 6
RANDOM PEERS: Got 0 peers
```
(Mainnet operator can't find peers when using non-standard ports)

**Why This Happens:**
- Both networks try to use the same default ports (31313/31314)
- Only one service can bind to a port at a time
- Mainnet operators need standard ports (31313/31314) for peer discovery on the network
- Testnet operators can use custom ports since they primarily connect to known peers

**Solution: Port Assignment Strategy**

**Mainnet Operator (needs standard ports for peer discovery):**
- Directory: `~/Drosera-Network-Mainnet`
- P2P Port: `31313` (standard - required for network peer discovery)
- Server Port: `31314`

**Hoodi Testnet Operator (can use custom ports):**
- Directory: `~/Drosera-Network-Hoodi`
- P2P Port: `50000` (custom)
- Server Port: `50001`

**Step-by-Step Fix:**

1. **Check what's using the ports:**
```bash
sudo lsof -i :31313
sudo lsof -i :31314
```

2. **Stop existing operators:**
```bash
# Stop Hoodi operator
cd ~/Drosera-Network-Hoodi
docker compose down

# Stop Mainnet operator (if running)
cd ~/Drosera-Network-Mainnet
docker compose down
```

3. **Update Mainnet docker-compose.yaml (use standard ports):**
```yaml
services:
  drosera-operator:
    environment:
      - DRO__NETWORK__P2P_PORT=31313
      - DRO__SERVER__PORT=31314
    ports:
      - "31313:31313"
      - "31314:31314"
```

4. **Update Hoodi docker-compose.yaml (use custom ports):**
```yaml
services:
  drosera-operator:
    environment:
      - DRO__NETWORK__P2P_PORT=50000
      - DRO__SERVER__PORT=50001
    ports:
      - "50000:50000"
      - "50001:50001"
```

5. **Open firewall for both sets of ports:**
```bash
# Mainnet ports
sudo ufw allow 31313/tcp
sudo ufw allow 31314/tcp

# Hoodi ports
sudo ufw allow 50000/tcp
sudo ufw allow 50001/tcp
```

6. **Restart operators:**
```bash
# Start mainnet first (gets standard ports)
cd ~/Drosera-Network-Mainnet
docker compose up -d

# Start Hoodi (uses custom ports)
cd ~/Drosera-Network-Hoodi
docker compose up -d
```

7. **Verify both are running:**
```bash
docker ps | grep drosera
sudo netstat -tulpn | grep -E "31313|31314|50000|50001"
```

**Why This Configuration Works:**
- Mainnet operators on the broader network use standard ports for peer discovery - your mainnet operator will find peers
- Hoodi testnet operators can use custom ports and still function properly
- No port conflicts between the two networks
- Both operators run simultaneously on the same machine

</details>

---

<details>
<summary>Still having issues? Try one of the following options:</summary>

- Copy your error logs or take a screenshot of the issue.  
- Join the [Drosera Discord](https://discord.gg/drosera) and post in **[#technical](https://discord.com/channels/1195369272554303508/1207372870972604447)** with your error, current step, network, and what you’ve tried.  
- Paste the full error into an AI tool (e.g., ChatGPT or Claude) for troubleshooting help.  
- Check the official Drosera documentation, GitHub releases, or network status for known issues.

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
<summary>Advanced: Multi-Signal Monitoring (Optional) </summary>

**For experienced users only.** If you're building your first trap, skip this section and keep your logic simple.

### What is Multi-Signal Monitoring?

Checking multiple independent data sources and triggering only when several agree.

**Example:** Instead of just monitoring pool reserves, also check price deviation and transaction volume. Trigger only if 2 out of 3 signals indicate a threat.

### When to Use

- ✅ Monitoring complex DeFi protocols where single metrics can be manipulated
- ✅ Reducing false positives from oracle failures or temporary anomalies
- ✅ Catching sophisticated attacks that avoid single detection vectors

### When NOT to Use

- ❌ Simple threshold checks (e.g., "trigger if gas > 100 gwei")
- ❌ Your first trap (start simple, add complexity later if needed)
- ❌ Single data source monitoring (no benefit to multi-signal)

### Pattern Example

```solidity
function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
    // Safety check
    if (data.length == 0 || data[0].length == 0) return (false, bytes(""));

    // Decode independent signals
    (uint256 reserves, uint256 priceDeviation, uint256 volume) = abi.decode(data[0], (uint256, uint256, uint256));
    
    // Check each signal independently
    bool signal1 = reserves < RESERVE_THRESHOLD;
    bool signal2 = priceDeviation > PRICE_THRESHOLD;
    bool signal3 = volume > VOLUME_THRESHOLD;
    
    // Count how many signals detected threat
    uint8 triggered = 0;
    if (signal1) triggered++;
    if (signal2) triggered++;
    if (signal3) triggered++;
    
    // Trigger if 2 of 3 signals agree
    if (triggered >= 2) {
        return (true, abi.encode(reserves, priceDeviation, volume));
    }
    
    return (false, bytes(""));
}
```

**Key principle:** Each signal should be truly independent (different data sources, not just different thresholds on the same data).

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
<summary>Good Example: Simple Reserve Monitor</summary>

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

interface IVault {
    function totalAssets() external view returns (uint256);
}

contract ReserveMonitorTrap is ITrap {
    IVault public immutable vault;
    uint256 public constant MIN_RESERVE = 1000 ether;
    
    constructor(address _vault) {
        vault = IVault(_vault);
    }
    
    function collect() external view override returns (bytes memory) {
        uint256 reserves = vault.totalAssets();
        return abi.encode(reserves, block.number);
    }
    
    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        // Safety check
        if (data.length == 0 || data[0].length == 0) return (false, bytes(""));
        
        (uint256 reserves, uint256 blockNumber) = abi.decode(data[0], (uint256, uint256));
        
        // Trigger if reserves drop below minimum
        if (reserves < MIN_RESERVE) {
            return (true, abi.encode(reserves, blockNumber));
        }
        
        return (false, bytes(""));
    }
}
```

**Why this is good:**
- Monitors specific vulnerability (reserve depletion)
- Single clear threshold (1000 ETH minimum)
- Minimal external dependencies
- Proper safety checks
- Easy to understand and modify
- Silent unless reserves are critically low

</details>

---

<details>
<summary>Good Example: Oracle Deviation Detector</summary>

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

interface AggregatorV3Interface {
    function latestRoundData() external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );
}

interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

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
        (, int256 answer, , uint256 updatedAt, ) = chainlinkFeed.latestRoundData();
        
        // Validate Chainlink data
        if (answer <= 0 || updatedAt == 0) {
            return bytes("");
        }
        
        // Get Uniswap price
        (uint112 reserve0, uint112 reserve1, ) = uniswapPair.getReserves();
        
        // Validate reserves
        if (reserve0 == 0 || reserve1 == 0) {
            return bytes("");
        }
        
        uint256 chainlinkPrice = uint256(answer);
        uint256 uniswapPrice = (uint256(reserve1) * 1e18) / uint256(reserve0);
        
        return abi.encode(chainlinkPrice, uniswapPrice, block.timestamp);
    }
    
    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        // Safety check
        if (data.length == 0 || data[0].length == 0) return (false, bytes(""));

        (uint256 chainlinkPrice, uint256 uniswapPrice, uint256 timestamp) = abi.decode(
            data[0], 
            (uint256, uint256, uint256)
        );
        
        // Additional safety - both prices must be valid
        if (chainlinkPrice == 0 || uniswapPrice == 0) return (false, bytes(""));
        
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
- Monitors critical infrastructure (oracle price feeds)
- Compares multiple independent data sources (Chainlink vs Uniswap)
- Clear threshold (5% deviation)
- Detects real vulnerabilities (price manipulation, oracle failures)
- Proper validation (zero checks, staleness checks)
- Silent by default
- Handles edge cases safely (returns empty bytes if data invalid)

</details>

---

## Additional Resources

- **[Drosera Documentation](https://docs.drosera.io)** - Official network docs
- **[Foundry Book](https://book.getfoundry.sh)** - Smart contract development
- **[Solidity Documentation](https://docs.soliditylang.org)** - Language reference
- **[Discord Community](https://discord.gg/drosera)** - Get help and support

---

**[← Back to Quick Start](README.md)**
