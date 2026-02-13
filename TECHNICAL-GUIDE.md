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

### Essential Requirements

- **Ubuntu VPS** with SSH access (or similar Linux environment)
- **Ethereum wallet** with private key
- **GitHub account**
- **Drosera operator running** (Cadet and Corporal roles completed)
- **Basic terminal familiarity**

<details>
<summary>🔍 Click to expand: Verify operator status</summary>

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

### Network Selection

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

---

# 📍 Phase 1: Local Development

---

## 🔧 Step 1: Screen Session (Recommended)

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

---

## 🔧 Step 2: Project Setup

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

---

## 🔧 Step 3: Install Dependencies & Interface

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

---

## 🔧 Step 4: Create Contract Files

Create your trap contracts. 
- For AI-generated code, follow the [copilot prompt](https://github.com/Idle0x/Drosera-Unique-Trap/blob/main/README.md#-copy-the-complete-ai-copilot-prompt).
- For manual creation, use the guidelines below:

### 1. Trap Contract (`src/{TrapName}Trap.sol`):

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

### 2. Response Contract (`src/{TrapName}Response.sol`):

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

### 3. Deploy Script (`script/Deploy.sol`):

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

---

## 🔧 Step 5: Configuration Files

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
forge-std/=lib/forge-std/src/
drosera-contracts/=lib/drosera-contracts/
@openzeppelin/=lib/openzeppelin-contracts/
```

**Save with:** `Ctrl+X`, `Y`, `Enter`

---

## 🔧 Step 6: Build & Test

**Compile contracts:**
```bash
forge build
```

✅ **Expected output:** `Compiler run successful`

**Test locally (optional):**
```bash
forge test
```

---

# 📍 Phase 2: Drosera Integration

---

## 🔧 Step 1: Deploy Response Contract

Set up environment variables:

```bash
nano .env
```

```env
PRIVATE_KEY=your_private_key_here
RPC_URL=your_rpc_url_here
ETHERSCAN_API_KEY=your_api_key_here
```

**For Hoodi Testnet:**
```env
RPC_URL=https://rpc.hoodi.ethpandaops.io
```

**For Ethereum Mainnet:**
```env
RPC_URL=https://eth.llamarpc.com
```

**Save with:** `Ctrl+X`, `Y`, `Enter`

---

**Deploy the Response contract:**

```bash
source .env
forge script script/Deploy.sol:DeployScript --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
```

✅ **Expected output:** `Response deployed at: 0x...`

**Copy the Response contract address** - you'll need it for the next step.

---

## 🔧 Step 2: Configure drosera.toml

Create the Drosera configuration file:

```bash
nano drosera.toml
```

**For Hoodi Testnet:**

```toml
ethereum_rpc = "https://rpc.hoodi.ethpandaops.io"
drosera_rpc  = "https://relay.hoodi.drosera.io"
eth_chain_id = 560048
drosera_address = "0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D"

[traps.your_trap_name]
path = "out/YourTrap.sol/YourTrap.json"
response_contract = "0xYOUR_RESPONSE_ADDRESS"
response_function = "yourFunction(uint256,address)"
cooldown_period_blocks = 50
min_number_of_operators = 1
max_number_of_operators = 3
block_sample_size = 1
private_trap = true
whitelist = ["0xYOUR_WALLET_ADDRESS"]
gas_limit = 500000
```

**For Ethereum Mainnet:**

```toml
ethereum_rpc = "https://eth.llamarpc.com"
drosera_rpc  = "https://relay.drosera.io"
eth_chain_id = 1
drosera_address = "0x0c4f7e9684a11805Fc5406989F5124bFC2AD0D84"

[traps.your_trap_name]
path = "out/YourTrap.sol/YourTrap.json"
response_contract = "0xYOUR_RESPONSE_ADDRESS"
response_function = "yourFunction(uint256,address)"
cooldown_period_blocks = 50
min_number_of_operators = 1
max_number_of_operators = 3
block_sample_size = 1
private_trap = true
whitelist = ["0xYOUR_WALLET_ADDRESS"]
gas_limit = 500000
```

**Replace:**
- `your_trap_name`: Snake_case identifier for your trap
- `YourTrap.sol/YourTrap.json`: Your actual trap filename
- `0xYOUR_RESPONSE_ADDRESS`: Address from Step 1
- `yourFunction(uint256,address)`: Your Response contract's function signature
- `0xYOUR_WALLET_ADDRESS`: Your operator wallet address

**Save with:** `Ctrl+X`, `Y`, `Enter`

---

## 🔧 Step 3: Dry Run Test

Test your trap logic locally before deploying:

```bash
drosera dryrun
```

✅ **Expected output:**
```
Testing trap(s) execution...
trap_name: your_trap_name
result: Success
should_respond: false
```

If `should_respond: true`, verify this is expected behavior (e.g., you're testing an alert condition).

---

## 🔧 Step 4: Apply Trap Configuration

Deploy your trap to the Drosera Network:

```bash
DROSERA_PRIVATE_KEY=your_private_key_here drosera apply
```

When prompted, type `ofc` and press Enter.

✅ **Expected output:**
```
Transaction Hash: 0x...
Created Trap Config for your_trap_name
address: 0x...
```

**Copy the trap config address** - you'll need it for Phase 3.

---

**Update drosera.toml with trap address:**

```bash
nano drosera.toml
```

Add this line under your trap configuration:
```toml
address = "0xYOUR_TRAP_CONFIG_ADDRESS"
```

**Save with:** `Ctrl+X`, `Y`, `Enter`

---

# 📍 Phase 3: Operator Setup

Now that your trap is deployed, you need to run an **Operator Node** to monitor it. The operator executes your trap's logic every block and triggers your Response contract when needed.

---

## 🔧 Step 1: Create Operator Directory

```bash
cd ~
mkdir drosera-operator
cd drosera-operator
```

---

## 🔧 Step 2: Install Docker (Skip if Already Installed)

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

---

## 🔧 Step 3: Create Environment File

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

---

## 🔧 Step 4: Create Docker Configuration

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

---

## 🔧 Step 5: Configure Firewall

```bash
sudo ufw allow 22/tcp
sudo ufw allow 31313/tcp
sudo ufw allow 31314/tcp
sudo ufw enable
sudo ufw status
```

---

## 🔧 Step 6: Start the Operator

```bash
docker pull ghcr.io/drosera-network/drosera-operator:latest
docker compose up -d
docker compose logs -f --tail=30
```

✅ **Look for:** `Starting Drosera Operator` and `P2P node started`

Press `Ctrl+C` to exit logs.

---

## 🔧 Step 7: Register Your Operator

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

---

## 🔧 Step 8: Opt-In to Your Trap

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

---

## 🔧 Step 9: Verify Operation

```bash
docker compose logs -f --tail=50
```

✅ **Look for:**
```
Executing trap collect() for config 0x...
shouldRespond returned: false
```

This confirms your operator is monitoring your trap.

---

## 🔧 Step 10: Dashboard Verification

1. Go to https://app.drosera.io/
2. Connect your wallet
3. Switch to your network (Hoodi or Mainnet)
4. Navigate to "My Traps"
5. Check your trap shows **Green (Active)** status

---

### Useful Commands

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

---

# 📍 Phase 4: GitHub Publication

---

## 🔧 Step 1: Secure Your Repository

**CRITICAL: Protect your private keys before pushing to GitHub.**

Check your `.gitignore`:
```bash
cat .gitignore
```

Ensure it contains:
```
.env
*.env
.env.*
```

If not, add it:
```bash
echo ".env" >> .gitignore
```

---

## 🔧 Step 2: Initialize Git Repository

```bash
git init
git add .
git commit -m "Initial commit: Drosera trap deployment"
git branch -M main
```

---

## 🔧 Step 3: Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: `your-trap-name`
3. Description: Brief description of your trap
4. Visibility: **Public** (required for Drosera verification)
5. **Do NOT** initialize with README, .gitignore, or license
6. Click "Create repository"

---

## 🔧 Step 4: Push to GitHub

```bash
git remote add origin https://github.com/YOUR_USERNAME/your-trap-name.git
git push -u origin main
```

**Authentication:**
- Username: Your GitHub username
- Password: Use a **Personal Access Token** (not your password)
  - Generate at: Settings → Developer settings → Personal access tokens → Tokens (classic)
  - Select `repo` scope
  - Copy and paste the token when prompted

---

## 🔧 Step 5: Create README.md

```bash
nano README.md
```

**Template:**

```markdown
# [Your Trap Name]

## Overview
Brief description of what your trap monitors and why.

## Architecture
- **Target Contract:** `0x...` (what you're monitoring)
- **Trap Contract:** `0x...` (your trap config address)
- **Response Contract:** `0x...` (your response address)

## Trigger Conditions
Explain when your trap triggers (e.g., "Triggers if treasury balance < 500,000 tokens")

## Network
- Hoodi Testnet / Ethereum Mainnet
- Chain ID: 560048 / 1

## Setup
See [TECHNICAL-GUIDE.md](TECHNICAL-GUIDE.md) for complete setup instructions.

## Verification
View on Drosera Dashboard: https://app.drosera.io/
```

**Save and push:**
```bash
git add README.md
git commit -m "Add README"
git push
```

---

# 📍 Phase 5: Dashboard Verification

---

## 🔧 Step 1: Access Dashboard

Navigate to https://app.drosera.io/

---

## 🔧 Step 2: Connect Wallet

1. Click "Connect Wallet"
2. Select your wallet provider (MetaMask, WalletConnect, etc.)
3. Approve the connection
4. Switch to the correct network (Hoodi or Mainnet)

---

## 🔧 Step 3: Locate Your Trap

1. Go to "My Traps" section
2. Search by:
   - Your wallet address, OR
   - Your trap config address

---

## 🔧 Step 4: Verify Trap Status

✅ **Your trap should show:**
- **Status:** Green (Active)
- **Operators:** List of opted-in operators
- **Last Execution:** Recent timestamp
- **Blocks Processed:** Incrementing number
- **shouldRespond History:** Mostly `false` (good - silent watchdog)

---

## 🔧 Step 5: Monitor Execution Logs

Click on your trap to view detailed logs:
- `collect()` execution results
- `shouldRespond()` evaluations
- Response contract calls (if triggered)
- Gas consumption per execution

---

## 🔧 Step 6: Bloom Boost (Optional)

To increase trap priority and response speed:

```bash
drosera bloomboost --trap-address YOUR_TRAP_ADDRESS --eth-amount 0.1
```

This deposits ETH to boost your trap's execution priority.

---

## 🔧 Step 7: Test Your Trap (Recommended)

Simulate the condition that should trigger your trap:

1. Execute a test transaction that meets your trigger criteria
2. Wait 1-2 blocks for operator execution
3. Check dashboard for `shouldRespond: true`
4. Verify Response contract was called
5. Check event logs for expected output

---

# Troubleshooting

---

<details>
<summary>❌ Issue: "Compiler run failed" during forge build</summary>

**Possible causes:**
- Missing dependencies
- Wrong Solidity version
- Import path errors

**Solutions:**

1. **Check Solidity version in foundry.toml:**
   ```bash
   nano foundry.toml
   ```
   Ensure `solc = "0.8.20"`

2. **Verify remappings.txt:**
   ```bash
   cat remappings.txt
   ```

3. **Reinstall dependencies:**
   ```bash
   rm -rf lib/
   forge install foundry-rs/forge-std@v1.8.2 --no-commit
   forge install OpenZeppelin/openzeppelin-contracts@v5.0.2 --no-commit
   ```

4. **Clean and rebuild:**
   ```bash
   forge clean
   forge build
   ```

</details>

---

<details>
<summary>❌ Issue: "drosera dryrun" fails with "reverted without reason"</summary>

**Common causes:**
- Target contract doesn't exist on the network
- Wrong contract address
- `collect()` function calling non-existent contract

**Solutions:**

1. **Verify target contract exists:**
   ```bash
   cast code YOUR_TARGET_ADDRESS --rpc-url YOUR_RPC_URL
   ```
   Should return bytecode (not `0x`)

2. **Check if address is checksummed:**
   ```bash
   cast to-check-sum-address YOUR_ADDRESS
   ```

3. **Test collect() directly:**
   ```bash
   cast call YOUR_TRAP_ADDRESS "collect()" --rpc-url YOUR_RPC_URL
   ```

</details>

---

<details>
<summary>❌ Issue: "drosera apply" transaction fails</summary>

**Possible causes:**
- Insufficient gas
- Wrong network configuration
- Trap already deployed at this address

**Solutions:**

1. **Check wallet balance:**
   ```bash
   cast balance YOUR_ADDRESS --rpc-url YOUR_RPC_URL
   ```

2. **Verify drosera.toml network settings:**
   - `eth_chain_id` matches your network
   - `drosera_address` is correct for your network
   - `ethereum_rpc` is accessible

3. **Increase gas limit in drosera.toml:**
   ```toml
   gas_limit = 1000000
   ```

4. **If trap already exists, update instead:**
   ```bash
   DROSERA_PRIVATE_KEY=xxx drosera apply --update
   ```

</details>

---

<details>
<summary>❌ Issue: Docker container keeps restarting</summary>

**Check logs:**
```bash
docker compose logs --tail=100
```

**Common issues:**

1. **Missing `.env` file:**
   ```bash
   ls -la .env
   ```
   If missing, recreate with `ETH_PRIVATE_KEY` and `VPS_IP`

2. **Invalid private key format:**
   - Must start with `0x`
   - Must be 64 hex characters after `0x`

3. **Port conflicts:**
   ```bash
   sudo lsof -i :31313
   sudo lsof -i :31314
   ```
   If ports are in use, change in docker-compose.yaml

4. **Wrong command format:**
   Ensure docker-compose.yaml has:
   ```yaml
   command: ["node"]
   ```

</details>

---

<details>
<summary>❌ Issue: Operator registration fails with "FunctionDoesNotExist"</summary>

**Causes:**
- Outdated Drosera CLI
- Wrong Drosera contract address

**Solutions:**

1. **Update Drosera CLI:**
   ```bash
   curl -L https://app.drosera.io/install | bash
   source ~/.bashrc
   droseraup
   ```

2. **Verify correct Drosera address for your network:**
   - Hoodi: `0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D`
   - Mainnet: `0x0c4f7e9684a11805Fc5406989F5124bFC2AD0D84`

3. **Use Docker registration method:**
   ```bash
   source .env && docker run -it --rm ghcr.io/drosera-network/drosera-operator:latest register \
     --eth-chain-id YOUR_CHAIN_ID \
     --eth-rpc-url YOUR_RPC \
     --drosera-address YOUR_DROSERA_ADDRESS \
     --eth-private-key $ETH_PRIVATE_KEY
   ```

</details>

---

<details>
<summary>❌ Issue: Trap shows "Red" status on dashboard</summary>

**Possible causes:**
- Operator not running
- Operator not opted into trap
- Network connectivity issues
- Firewall blocking ports

**Solutions:**

1. **Check operator status:**
   ```bash
   docker compose ps
   docker compose logs --tail=50
   ```

2. **Verify opt-in:**
   ```bash
   # Re-run opt-in command
   source .env && docker run -it --rm ghcr.io/drosera-network/drosera-operator:latest optin \
     --eth-rpc-url YOUR_RPC \
     --eth-private-key $ETH_PRIVATE_KEY \
     --trap-config-address YOUR_TRAP_ADDRESS
   ```

3. **Check firewall:**
   ```bash
   sudo ufw status
   ```
   Ensure 31313 and 31314 are open

4. **Verify RPC connectivity:**
   ```bash
   curl -X POST YOUR_RPC_URL \
     -H "Content-Type: application/json" \
     -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
   ```

</details>

---

<details>
<summary>❌ Issue: GitHub push rejected</summary>

**Authentication issues:**

1. **Using password instead of token:**
   - GitHub no longer accepts passwords for git operations
   - Generate Personal Access Token at: https://github.com/settings/tokens
   - Select `repo` scope
   - Use token as password when prompted

2. **Token expired:**
   - Generate new token with same steps above

3. **Wrong remote URL:**
   ```bash
   git remote -v
   ```
   Should show `https://github.com/YOUR_USERNAME/repo.git`

   If wrong:
   ```bash
   git remote set-url origin https://github.com/YOUR_USERNAME/your-trap-name.git
   ```

</details>

---

# Trap Quality Standards

---

## What Makes a Good Trap?

### Silent Watchdog Pattern
- **Returns false most of the time** - Only triggers on critical events
- **Efficient gas usage** - Operators can run sustainably
- **Clear trigger conditions** - Well-defined thresholds
- **Flexible thresholds (3+ vectors)** - Adapts to partial attack patterns

---

### Flexible Threshold Logic (For 3+ Vector Traps)
For traps monitoring multiple conditions:
- **3-vector traps:** Trigger if ANY 2 or ALL 3 conditions met
- **4-vector traps:** Trigger if ANY 3 or ALL 4 conditions met
- **5-vector traps:** Trigger if ANY 3+ or ALL 5 conditions met

**Why this matters:**
- ✅ Catches threats even if one data source fails
- ✅ Reduces false negatives
- ✅ Still maintains low noise (requires multiple confirmations)
- ✅ More resilient to oracle issues or network delays

---

### Example: Good Flexible Threshold Logic
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

---

## What to Avoid

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

---

## Best Practices

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

---

# Examples: Good vs Bad Traps

---

<details>
<summary>❌ Bad Example: Always-Respond Trap</summary>

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
<summary>❌ Bad Example: Generic Gas Monitor</summary>

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
<summary>✅ Good Example: Multivector Liquidity Monitor</summary>

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
<summary>✅ Good Example: Oracle Deviation Detector</summary>

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
