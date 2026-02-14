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

<details>
<summary><h2>Prerequisites</h2></summary>

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

<details>
<summary><h2>Network Selection</h2></summary>

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

<details open>
<summary>▶️ Click to expand/collapse</summary>

<details open>
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

<details open>
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

<details open>
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

<details open>
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

<details open>
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
solc = "0.8.20"
optimizer = true
optimizer_runs = 200
```

**Save with:** `Ctrl+X`, `Y`, `Enter`

---

**Create remappings.txt:**
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

**Save with:** `Ctrl+X`, `Y`, `Enter`

</details>

---

<details open>
<summary>Step 6: Compile</summary>

```bash
forge build
```

**Expected output:**
```
[⠊] Compiling...
[⠒] Compiling X files with 0.8.20
[⠑] Solc 0.8.20 finished in X.XXs
Compiler run successful!
```

**Verify artifacts were created:**
```bash
ls out/
ls out/{TrapName}Trap.sol/{TrapName}Trap.json
ls out/{TrapName}Response.sol/{TrapName}Response.json
```

**If compilation fails, see [Troubleshooting](#troubleshooting)**

</details>

---

<details open>
<summary>Step 7: Environment Setup</summary>

```bash
nano .env
```

Add your private key:
```
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

<details open>
<summary>Step 8: Deploy Response Contract</summary>

**For Hoodi Testnet:**
```bash
forge script script/Deploy.sol \
  --rpc-url https://rpc.hoodi.ethpandaops.io \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --legacy
```

**For Ethereum Mainnet:**
```bash
forge script script/Deploy.sol \
  --rpc-url https://eth.llamarpc.com \
  --private-key $PRIVATE_KEY \
  --broadcast
```

**Save your Response contract address from the output!**

**Verify deployment:**
```bash
# Replace with your actual Response address
cast code 0xYOUR_RESPONSE_ADDRESS --rpc-url https://rpc.hoodi.ethpandaops.io
```
Expected: Long hex string (bytecode). If you see `0x`, the contract was NOT deployed.

</details>

---

### ✅ Phase 1 Complete

**Next Step:** Proceed to [Phase 2: Drosera Integration](#phase-2-drosera-integration) to deploy your trap to the Drosera Network.

</details>

---

## Phase 2: Drosera Integration

<details>
<summary>▶️ Click to expand/collapse</summary>

<details>
<summary>Step 1: Create drosera.toml</summary>

```bash
cd ~/{your-folder-name}
nano drosera.toml
```

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
response_function = "yourFunction(type1,type2)"
cooldown_period_blocks = 33
min_number_of_operators = 1
max_number_of_operators = 3
block_sample_size = 1
private = true
whitelist = ["0xYOUR_WALLET_ADDRESS"]
private_trap = true

# CRITICAL: DO NOT add 'address = ...' here
# Drosera will auto-deploy the Trap and fill this field
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
response_function = "yourFunction(type1,type2)"
cooldown_period_blocks = 100
min_number_of_operators = 2
max_number_of_operators = 5
block_sample_size = 1
private = true
whitelist = ["0xYOUR_WALLET_ADDRESS"]
private_trap = true

# CRITICAL: DO NOT add 'address = ...' here
# Drosera will auto-deploy the Trap and fill this field
```

**Key Fields Explained:**

- **`path`**: Location of your compiled Trap JSON artifact
- **`response_contract`**: Address where you deployed your Response contract
- **`response_function`**: EXACT function signature from your Response contract
  - Format: `"functionName(type1,type2,type3)"`
  - No spaces, must match exactly
  - Example: `"handleAlert(uint256,uint256,bytes32)"`
- **`cooldown_period_blocks`**: Minimum blocks between trap responses (prevents spam)
- **`block_sample_size`**: Historical blocks passed to `shouldRespond()`
  - `1` = Only current block data
  - `5-10` = Time-series analysis (requires loop in shouldRespond)
- **`whitelist`**: Your operator wallet address
- **`private_trap`**: Set to `true` to keep trap private to your operators

> **⚠️ CRITICAL:** Do NOT manually add `address = "0x..."` field. Drosera fills this automatically when you run `drosera apply`.

**Save with:** `Ctrl+X`, `Y`, `Enter`

**Verify configuration:**
```bash
cat drosera.toml
```

</details>

---

<details>
<summary>Step 2: Verify Response Function Matches</summary>

**CRITICAL CHECK:** The `response_function` in TOML must EXACTLY match your Response contract.

```bash
# Check your Response contract's function
grep "function" src/YourResponse.sol
```

Example:
- If Response has: `function handleAlert(uint256 price, uint256 timestamp)`
- TOML must have: `response_function = "handleAlert(uint256,uint256)"`

**Common mistakes:**
- ❌ Including spaces: `"handleAlert(uint256, uint256)"`
- ❌ Wrong function name
- ❌ Wrong parameter types or count

</details>

---

<details>
<summary>Step 3: Test Configuration (Dry Run)</summary>

```bash
drosera dryrun
```

**Expected output:**
```
✓ Configuration valid
✓ Trap artifact found
✓ Response contract exists
✓ Planning successful
```

**If errors occur, see [Troubleshooting](#troubleshooting)**

</details>

---

<details>
<summary>Step 4: Deploy to Drosera Network</summary>

```bash
source .env
DROSERA_PRIVATE_KEY=$PRIVATE_KEY drosera apply
```

**What happens:**
1. Drosera reads your compiled Trap from `path` in TOML
2. Drosera deploys the Trap contract automatically
3. Drosera registers trap with operator network
4. Drosera updates your `drosera.toml` with the Trap address

**Expected output:**
```
Deploying trap...
✓ Trap deployed at: 0xABC123...
✓ Configuration updated
```

**Verify Trap address was added to TOML:**
```bash
cat drosera.toml | grep "address ="
```

Expected to see: `address = "0x..."`

**If errors, see [Troubleshooting](#troubleshooting)**

</details>

---

<details>
<summary>Step 5: Authorize Operator in Response Contract</summary>

**Find your operator address:**
```bash
drosera operator info
```
Or check the `whitelist` field in your drosera.toml

**Authorize the operator to call your Response contract:**
```bash
cast send YOUR_RESPONSE_ADDRESS \
  "setOperator(address,bool)" \
  YOUR_OPERATOR_ADDRESS \
  true \
  --rpc-url https://rpc.hoodi.ethpandaops.io \
  --private-key $PRIVATE_KEY
```

**Verify authorization:**
```bash
cast call YOUR_RESPONSE_ADDRESS \
  "authorizedOperators(address)(bool)" \
  YOUR_OPERATOR_ADDRESS \
  --rpc-url https://rpc.hoodi.ethpandaops.io
```

Expected: `true` (shown as hex: `0x0000...0001`)

</details>

---

### ✅ Phase 2 Complete

**Next Step:** Proceed to [Phase 3: Operator Setup](#phase-3-operator-setup) to run your operator node.

</details>

---

## Phase 3: Operator Setup

<details>
<summary>▶️ Click to expand/collapse</summary>

Now that your trap is deployed, you need to run an **Operator Node** to monitor it. The operator executes your trap's logic every block and triggers your Response contract when needed.

---

<details>
<summary>Step 1: Create Operator Directory</summary>

```bash
cd ~
mkdir drosera-operator
cd drosera-operator
```

</details>

---

<details>
<summary>Step 2: Install Docker (Skip if Already Installed)</summary>

Check if Docker is installed:
```bash
docker --version
```

**If not installed, run:**

```bash
sudo apt update -y && sudo apt upgrade -y

for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do 
  sudo apt-get remove $pkg 2>/dev/null
done

sudo apt-get install ca-certificates curl gnupg -y
sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

sudo docker run hello-world
```

</details>

---

<details>
<summary>Step 3: Create Environment File</summary>

```bash
nano .env
```

**Paste and replace with your values:**

```env
ETH_PRIVATE_KEY=your_private_key_here
VPS_IP=your_server_ip_here
```

**Example:**
```env
ETH_PRIVATE_KEY=0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890
VPS_IP=203.0.113.45
```

💡 **Note:** Find your IP at https://whatismyip.com. If testing locally, use `127.0.0.1`.

**Save:** `Ctrl+X`, `Y`, `Enter`

</details>

---

<details>
<summary>Step 4: Create Docker Configuration</summary>

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
    command: ["node"]
    ports:
      - "31313:31313"
      - "31314:31314"
    environment:
      - DRO__DB_FILE_PATH=/data/drosera.db
      - DRO__DROSERA_ADDRESS=0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D
      - DRO__LISTEN_ADDRESS=0.0.0.0
      - DRO__DISABLE_DNR_CONFIRMATION=true
      - DRO__ETH__CHAIN_ID=560048
      - DRO__ETH__RPC_URL=https://rpc.hoodi.ethpandaops.io
      - DRO__ETH__BACKUP_RPC_URL=https://ethereum-hoodi-rpc.publicnode.com
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

volumes:
  drosera_data:
```

**For Ethereum Mainnet (change these values):**
- `DRO__DROSERA_ADDRESS=0x0c4f7e9684a11805Fc5406989F5124bFC2AD0D84`
- `DRO__ETH__CHAIN_ID=1`
- `DRO__ETH__RPC_URL=https://eth.llamarpc.com`
- `DRO__ETH__BACKUP_RPC_URL=https://rpc.ankr.com/eth`

**Save:** `Ctrl+X`, `Y`, `Enter`

</details>

---

<details>
<summary>Step 5: Configure Firewall</summary>

```bash
sudo ufw allow 22/tcp
sudo ufw allow 31313/tcp
sudo ufw allow 31314/tcp
sudo ufw enable
sudo ufw status
```

</details>

---

<details>
<summary>Step 6: Start the Operator</summary>

```bash
docker pull ghcr.io/drosera-network/drosera-operator:latest
docker compose up -d
docker compose logs -f --tail=30
```

✅ **Look for:** `Starting Drosera Operator` and `P2P node started`

Press `Ctrl+C` to exit logs.

</details>

---

<details>
<summary>Step 7: Register Your Operator</summary>

**Hoodi Testnet:**
```bash
source .env && docker run -it --rm ghcr.io/drosera-network/drosera-operator:latest register \
  --eth-chain-id 560048 \
  --eth-rpc-url https://rpc.hoodi.ethpandaops.io \
  --drosera-address 0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D \
  --eth-private-key $ETH_PRIVATE_KEY
```

**Ethereum Mainnet:**
```bash
source .env && docker run -it --rm ghcr.io/drosera-network/drosera-operator:latest register \
  --eth-chain-id 1 \
  --eth-rpc-url https://eth.llamarpc.com \
  --drosera-address 0x0c4f7e9684a11805Fc5406989F5124bFC2AD0D84 \
  --eth-private-key $ETH_PRIVATE_KEY
```

✅ **Expected:** `Transaction hash: 0x...` and `Successfully registered operator.`

</details>

---

<details>
<summary>Step 8: Opt-In to Your Trap</summary>

Replace `YOUR_TRAP_ADDRESS_HERE` with your trap config address from Phase 2.

**Hoodi Testnet:**
```bash
source .env && docker run -it --rm ghcr.io/drosera-network/drosera-operator:latest optin \
  --eth-rpc-url https://rpc.hoodi.ethpandaops.io \
  --eth-private-key $ETH_PRIVATE_KEY \
  --trap-config-address YOUR_TRAP_ADDRESS_HERE
```

**Ethereum Mainnet:**
```bash
source .env && docker run -it --rm ghcr.io/drosera-network/drosera-operator:latest optin \
  --eth-rpc-url https://eth.llamarpc.com \
  --eth-private-key $ETH_PRIVATE_KEY \
  --trap-config-address YOUR_TRAP_ADDRESS_HERE
```

✅ **Expected:** `Successfully opted into trap.`

</details>

---

<details>
<summary>Step 9: Verify Operation</summary>

```bash
docker compose logs -f --tail=50
```

✅ **Look for:**
```
Executing trap collect() for config 0x...
shouldRespond returned: false
```

This confirms your operator is monitoring your trap.

</details>

---

<details>
<summary>Step 10: Dashboard Verification</summary>

1. Go to https://app.drosera.io/
2. Connect your wallet
3. Switch to your network (Hoodi or Mainnet)
4. Navigate to "My Traps"
5. Check your trap shows **Green (Active)** status

</details>

---

<details>
<summary>Useful Commands</summary>

**View logs:**
```bash
docker compose logs -f
```

**Restart operator:**
```bash
docker compose restart
```

**Stop operator:**
```bash
docker compose down
```

**Update operator:**
```bash
docker compose pull
docker compose up -d
```

**Monitor multiple traps:** Repeat Step 8 with different trap addresses.

</details>

---

### ✅ Phase 3 Complete

**Next Step:** Proceed to [Phase 4: GitHub Publication](#phase-4-github-publication) to publish your trap repository.

</details>

---

## Phase 4: GitHub Publication

<details>
<summary>▶️ Click to expand/collapse</summary>

<details>
<summary>Step 1: Create README.md</summary>

```bash
nano README.md
```

Your README should include:

**For Mainnet Traps:**
- What vulnerability/condition it monitors
- Why this monitoring is valuable (who benefits, TVL protected)
- How it's designed to be efficient (quiet by default, specific thresholds)
- Technical specifications (contracts monitored, data sources, trigger logic)
- Deployment details (addresses, network, parameters)
- How to verify it's working

**For Testnet Traps:**
- Explain it's a learning/testing trap
- What monitoring concept it demonstrates
- How to test the trigger conditions
- Educational value

**Save with:** `Ctrl+X`, `Y`, `Enter`

</details>

---

<details>
<summary>Step 2: Create .gitignore</summary>

```bash
nano .gitignore
```

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
```

**Save with:** `Ctrl+X`, `Y`, `Enter`

</details>

---

<details>
<summary>Step 3: Git Initialization</summary>

```bash
git init
git add .
git commit -m "Initial commit: [Your Trap Name]"
```

**Verify:**
```bash
git status
git log
```

</details>

---

<details>
<summary>Step 4: Create GitHub Repository</summary>

1. Go to **https://github.com/new**
2. **Repository name**: Use kebab-case (e.g., `oracle-staleness-trap`)
3. **Visibility**: Public
4. **Do NOT** initialize with README (you already have one)
5. Click **Create repository**

</details>

---

<details>
<summary>Step 5: Generate GitHub Token</summary>

1. Go to **https://github.com/settings/tokens**
2. Click **Generate new token (classic)**
3. **Scopes**: Select `repo` and `workflow`
4. Click **Generate token**
5. **Copy the token** immediately

</details>

---

<details>
<summary>Step 6: Push to GitHub</summary>

```bash
git remote add origin https://github.com/YOUR_USERNAME/your-trap-name.git
git branch -M main
git push -u origin main
```

**Authentication:**
- **Username**: Your GitHub username
- **Password**: Use your **Personal Access Token** (not your GitHub password)

</details>

---

<details>
<summary>Step 7: Verify Repository</summary>

1. Visit your GitHub repository URL
2. Verify README displays correctly
3. Check that `.env` is NOT visible (should be in .gitignore)
4. Confirm all contract files are present

</details>

---

### ✅ Phase 4 Complete

**Next Step:** Proceed to [Phase 5: Dashboard Verification](#phase-5-dashboard-verification) to confirm everything is working.

</details>

---

## Phase 5: Dashboard Verification

<details>
<summary>▶️ Click to expand/collapse</summary>

<details>
<summary>Step 1: Access Dashboard</summary>

Navigate to **https://app.drosera.io/**

</details>

---

<details>
<summary>Step 2: Connect Wallet</summary>

1. Click "Connect Wallet"
2. Select your wallet provider
3. Approve connection
4. Switch to correct network (Hoodi or Mainnet)

</details>

---

<details>
<summary>Step 3: Locate Your Trap</summary>

1. Go to "My Traps" or "Operators" section
2. Find your trap by:
   - Name matching your snake_case from TOML
   - Status: Active
   - Recent blocks

</details>

---

<details>
<summary>Step 4: Understand Block Colors</summary>

**Green Blocks:**
- ✅ Trap monitoring successfully
- ✅ `shouldRespond()` returned `false` (no threat detected)
- ✅ This is normal and expected behavior

**Red Blocks:**
- ⚠️ Either: `shouldRespond()` returned `true` (threat detected - response triggered)
- ⚠️ Or: Error occurred in trap execution
- Check operator logs to determine which

**Gray/No Blocks:**
- ⚠️ Trap not being executed
- Check operator status
- Verify TOML configuration

</details>

---

<details>
<summary>Step 5: Check Operator Logs</summary>

```bash
# View recent logs
journalctl -u drosera-operator -n 50 --no-pager

# Follow logs in real-time
journalctl -u drosera-operator -f
```

**Exit real-time view:** `Ctrl+C`

**Look for:**
- "Executing trap: your_trap_name"
- "Trap result: false" (good - no threat)
- "Trap result: true" (alert - threat detected)
- Any error messages

</details>

---

<details>
<summary>Step 6: Success Confirmation</summary>

✅ **Your trap is successfully deployed if:**
- Trap appears in dashboard
- Green blocks appearing regularly
- Operator logs show successful execution
- No error messages in logs

</details>

---

<details>
<summary>Step 7: Submit for Verification</summary>

Once working:
1. Take screenshot of dashboard showing trap name and green blocks
2. Go to Drosera Discord
3. Create ticket in verification channel
4. Submit: Screenshot, GitHub link, Trap address, Network

</details>

---

### ✅ All Phases Complete

**Congratulations!** Your Drosera trap is fully operational. Monitor the dashboard regularly and check the [Troubleshooting](#troubleshooting) section if issues arise.

</details>

---

## Troubleshooting

<details>
<summary>▶️ Click to expand/collapse</summary>

<details>
<summary>Issue 1: Compilation Errors (`forge build` fails)</summary>

**Common causes:**
- Missing dependencies
- Incorrect import paths
- Solidity version mismatch
- Wrong `shouldRespond` signature (`bytes[]` not `bytes`)

**Solutions:**

**Missing dependencies:**
```bash
forge install foundry-rs/forge-std@v1.8.2 --no-commit
forge install OpenZeppelin/openzeppelin-contracts@v5.0.2 --no-commit
ls lib/  # Verify both installed
```

**Check remappings:**
```bash
cat remappings.txt
# Verify paths match your imports
```

**Wrong shouldRespond signature:**
```bash
grep "shouldRespond" src/YourTrap.sol
```
Must be: `function shouldRespond(bytes[] calldata data)` not `function shouldRespond(bytes calldata data)`

**Visibility issues:**
- `collect()` must be `view` (not `pure`)
- `shouldRespond()` must be `pure` (not `view`)

</details>

---

<details>
<summary>Issue 2: Storage Variable Error (CRITICAL)</summary>

**Symptoms:**
- Trap compiles but never triggers
- Always returns `false` even when conditions should be met

**Diagnosis:** Trap contract has storage variables

**Why this fails:**
Drosera redeploys your trap on shadow-fork every block. ALL storage variables reset to default (zero/false). State never persists.

**Example of WRONG code:**
```solidity
contract BadTrap is ITrap {
    uint256 public lastPrice;  // ❌ Resets every block
    bool public triggered;     // ❌ Resets every block
```

**Fix:** Remove ALL storage variables. Use `constant` or `immutable` instead:
```solidity
contract GoodTrap is ITrap {
    uint256 public constant THRESHOLD = 1000;      // ✅ OK
    address public immutable targetContract;       // ✅ OK (set in constructor)
```

</details>

---

<details>
<summary>Issue 3: ABI Mismatch (CRITICAL)</summary>

**Symptoms:**
```
Error: execution reverted
Location: crates/planning/transaction_builder.rs
```

**Diagnosis:** Trap's return data doesn't match Response function parameters

**How it works:**
1. Trap's `shouldRespond()` returns: `abi.encode(A, B, C)`
2. Response function must expect: `function handle(A, B, C)`
3. TOML must specify: `response_function = "handle(A,B,C)"`

**All three MUST match exactly**

**Verification:**
```bash
# Check what Trap returns
grep "abi.encode" src/YourTrap.sol

# Check Response function
grep "function" src/YourResponse.sol

# Check TOML
grep "response_function" drosera.toml
```

**Example mismatch:**
- Trap returns: `abi.encode(uint256, uint256)`
- Response expects: `function handle(uint256)` ❌ WRONG - missing second param
- Fix Response to: `function handle(uint256, uint256)` ✅

</details>

---

<details>
<summary>Issue 4: Authorization Error</summary>

**Symptoms:**
```
Error: execution reverted
Reason: "not authorized" or "Only trap"
```

**Diagnosis:** Response contract blocking Drosera executor

**Wrong pattern (will fail):**
```solidity
// ❌ Trap doesn't call Response - Executor does!
modifier onlyTrap() {
    require(msg.sender == trapAddress, "Only trap");
    _;
}
```

**Correct pattern:**
```solidity
// ✅ Authorize operator addresses, not trap
mapping(address => bool) public authorizedOperators;

modifier onlyOperator() {
    require(authorizedOperators[msg.sender], "Not authorized");
    _;
}

function setOperator(address operator, bool authorized) external onlyOwner {
    authorizedOperators[operator] = authorized;
}
```

**Then authorize your operator:**
```bash
cast send RESPONSE_ADDRESS "setOperator(address,bool)" OPERATOR_ADDRESS true --rpc-url $RPC_URL --private-key $PRIVATE_KEY
```

</details>

---

<details>
<summary>Issue 5: Data Length Guard Missing</summary>

**Symptoms:**
- Red blocks in dashboard
- Logs show "execution reverted" or abi.decode error

**Diagnosis:** Missing check before decoding data

**Always start shouldRespond with:**
```solidity
function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
    // MANDATORY - Check data exists before decoding
    if (data.length == 0 || data[0].length == 0) {
        return (false, bytes(""));
    }
    
    // Now safe to decode
    (uint256 value) = abi.decode(data[0], (uint256));
    // ...
}
```

</details>

---

<details>
<summary>Issue 6: TOML Address Field Error</summary>

**Symptoms:**
```
Error: Trap already exists
Error: Planning failed - invalid trap config
```

**Diagnosis:** Manually added `address = "0x..."` in TOML

**Fix:**
```bash
nano drosera.toml
```

Remove any line with `address = "0x..."`

Drosera fills this automatically after `drosera apply`

</details>

---

<details>
<summary>Issue 7: Response Contract Not Found</summary>

**Symptoms:**
```
Error: Response contract not found at address
Error: Invalid bytecode
```

**Check if deployed:**
```bash
cast code YOUR_RESPONSE_ADDRESS --rpc-url $RPC_URL
```

- Long hex string = deployed ✅
- `0x` = NOT deployed ❌

**If not deployed, deploy it:**
```bash
forge script script/Deploy.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
```

**Then update TOML with correct address**

</details>

---

<details>
<summary>Issue 8: Trap Not Appearing in Dashboard</summary>

**Checks:**

**1. Operator running:**
```bash
systemctl status drosera-operator
```
Should show `active (running)`

**2. Correct network in dashboard:**
Verify dashboard is set to same network as your deployment

**3. Wait for propagation:**
Can take 1-5 minutes. Refresh dashboard.

**4. Check TOML has address:**
```bash
cat drosera.toml | grep "address ="
```
Should see trap address. If not, `drosera apply` didn't succeed.

</details>

---

<details>
<summary>Issue 9: "drosera dryrun" Fails</summary>

**Common causes:**

**Response function mismatch:**
```bash
grep "response_function" drosera.toml
grep "function" src/YourResponse.sol
# These must match exactly
```

**Invalid artifact path:**
```bash
ls out/YourTrap.sol/YourTrap.json
# File must exist
```

**Response contract not deployed:**
```bash
cast code RESPONSE_ADDRESS --rpc-url $RPC_URL
# Should return bytecode, not 0x
```

</details>

---

<details>
<summary>Issue 10: Red Blocks (Determining Cause)</summary>

**Check operator logs:**
```bash
journalctl -u drosera-operator -n 50 | grep "your_trap_name"
```

**If "Trap result: true":**
- ✅ Intended behavior - trap detected threat and triggered response
- This is GOOD if it's a real anomaly

**If "execution reverted" or error:**
- ❌ Error in trap logic
- Common causes:
  - External call fails in `collect()`
  - Division by zero
  - Array out of bounds
  - Missing data length check

**Fix: Add defensive checks:**
```solidity
function collect() external view returns (bytes memory) {
    // Wrap external calls
    (bool success, bytes memory data) = target.staticcall(...);
    if (!success) {
        return abi.encode(0);  // Return safe default instead of reverting
    }
    // ...
}

function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
    // Always check data exists
    if (data.length == 0 || data[0].length == 0) return (false, bytes(""));
    
    // Check for division by zero
    if (baseValue == 0) return (false, bytes(""));
    
    // ...
}
```

</details>

</details>

---

## Trap Quality Standards

<details>
<summary>▶️ Click to expand/collapse</summary>

<details>
<summary>What Makes a Good Trap?</summary>

### Silent Watchdog Pattern
- **Returns false most of the time** - Only triggers on critical events
- **Efficient gas usage** - Operators can run sustainably
- **Clear trigger conditions** - Well-defined thresholds
- **Flexible thresholds (3+ vectors)** - Adapts to partial attack patterns

</details>

---

<details>
<summary>Flexible Threshold Logic (For 3+ Vector Traps)</summary>

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

</details>

---

## Examples: Good vs Bad Traps

<details>
<summary>▶️ Click to expand/collapse</summary>

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

</details>

---

## Additional Resources

- **[Drosera Documentation](https://docs.drosera.io)** - Official network docs
- **[Foundry Book](https://book.getfoundry.sh)** - Smart contract development
- **[Solidity Documentation](https://docs.soliditylang.org)** - Language reference
- **[Discord Community](https://discord.gg/drosera)** - Get help and support

---

**[← Back to Quick Start](README.md)**
