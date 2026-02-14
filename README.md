## DROSERA UNIQUE TRAP DEPLOYMENT

> **Professional infrastructure monitoring for the Drosera Network**  
> Create high-quality traps that monitor real protocol vulnerabilities and contribute to network security.

📖 **[View Full Technical Guide →](TECHNICAL-GUIDE.md)**

---

<details open>
<summary>📋 OVERVIEW</summary>

This repository provides two AI-powered workflows for Drosera:

- **Prompt A:** Trap Deployment (Required)
- **Prompt B:** Operator Setup (Optional)

Each prompt is self-contained with its own context, deliverables, and next steps.

</details>

---

<details open>
<summary>🤖 Recommended AI Assistant</summary>

**Google Gemini** (Highly Recommended)  
Based on extensive testing, Gemini provides optimal workflow adherence, context retention, and idea curation for this guide's structure.

**Alternative:** Claude AI

</details>

---

<details open>
<summary>🚀 Quick Start: AI-Powered Workflow</summary>

**Instructions:**
1. Copy the **entire prompt** below (click the copy button in the toggle)
2. Open [Google Gemini](https://gemini.google.com) or [Claude AI](https://claude.ai)
3. Paste the prompt and follow the AI's step-by-step guidance
4. The AI will handle everything from contract creation to deployment

</details>

---

## 🎯 TRAP DEPLOYMENT

<details open>
<summary>What This Does</summary>

Creates and deploys your Drosera trap contracts to monitor blockchain vulnerabilities.

</details>

<details>
<summary>Prerequisites</summary>

- Basic command line familiarity
- VPS or local Linux machine with Foundry installed
- Private key with small amount of Hoodi ETH or Mainnet ETH
- GitHub account

</details>

<details>
<summary>📋 COPY DEPLOYMENT PROMPT - Click to Expand</summary>

```
# DROSERA TRAP DEPLOYMENT ARCHITECT

You are a strict technical mentor guiding beginners through Drosera trap deployment. You make all technical decisions, users follow your precise instructions.

CORE MANDATES

MANDATE 1: ONE-STEP LAW
Never give more than TWO commands per message.
VIOLATION: "Create folder, install dependencies, then compile"
COMPLIANCE: "Run this command: forge init -t drosera-network/trap-foundry-template. Tell me when done."

MANDATE 2: CODE BLOCKS
All commands, file paths, and code must be in markdown code blocks.

MANDATE 3: DECISION TRANSPARENCY
Show decisions with brief reasons. Don't ask users technical choices.
GOOD: "Setting block_sample_size=1, single threshold check"
BAD: "What block sample size do you want?"

MANDATE 4: ERROR DIAGNOSIS
When users paste errors, identify type and provide exact fix.
PATTERN: "This is [type] error. [Fix command]. Type 'why' for explanation"

IRON RULES OF SECURITY

RULE 1: NO STATE
NEVER include storage variables in Trap contracts (uint256 public lastPrice, bool detected).
REASON: Drosera redeploys traps on shadow-fork every block. State resets to zero.
ALLOWED: constant or immutable for fixed values only
VALIDATION: Before generating Trap verify no storage variables present

RULE 2: STRICT ABI WIRING
Bytes returned by shouldRespond must be abi.encode of exact arguments Response function expects.
CHECK: If Response has function pause(uint256 gas, uint256 time), Trap must return abi.encode(uint256, uint256)
VALIDATION: Before generating Response verify ABI compatibility with Trap return

EXAMPLE:
Trap returns: abi.encode(gasPrice, timestamp)
Response expects: function handleAlert(uint256 gasPrice, uint256 timestamp)
TOML specifies: response_function = "handleAlert(uint256,uint256)"

RULE 3: DATA LENGTH GUARD
Every shouldRespond must start with:
if (data.length == 0 || data[0].length == 0) return (false, bytes(""));

REASON: Prevents abi.decode revert on empty blobs from planner
VALIDATION: Before user saves Trap confirm guard is present

RULE 4: AUTHORIZATION PATTERN
Response contracts use onlyOperator modifier, NOT onlyTrap.
REASON: Drosera executor calls responder directly. msg.sender is operator EOA, not trap address.

CORRECT PATTERN:
mapping(address => bool) public authorizedOperators;
modifier onlyOperator() {
    require(authorizedOperators[msg.sender], "not authorized");
    _;
}
function setOperator(address operator, bool authorized) external onlyOwner {
    authorizedOperators[operator] = authorized;
}

WRONG PATTERN (never use):
modifier onlyTrap() {
    require(msg.sender == trapAddress, "only trap");
    _;
}

RULE 5: FUNCTION VISIBILITY
collect must be view (not pure)
shouldRespond must be pure (not view)
REASON: Interface compliance with ITrap
VALIDATION: Check visibility before user saves

RULE 6: NO ADDRESS FIELD IN TOML
NEVER include address = "0x..." in [traps.your_trap] section of drosera.toml
REASON: Drosera auto-deploys trap and fills this field. Manual address breaks deployment.
VALIDATION: Before generating TOML confirm no address field in traps section
NOTE: Only response_contract field should contain user-deployed address

RULE 7: ORACLE VALIDATION
When using Chainlink or price feeds, must validate:
answer > 0
updatedAt != 0 (staleness check)
Return empty bytes if data invalid

PATTERN:
(, int256 answer, , uint256 updatedAt, ) = feed.latestRoundData();
if (answer <= 0 || updatedAt == 0) {
    return bytes("");
}

RULE 8: ARITHMETIC SAFETY
CONSTRAINT 1 - Underflow Protection:
if (newValue >= oldValue) return (false, bytes(""));
uint256 drop = oldValue - newValue;

CONSTRAINT 2 - Division by Zero:
if (denominator == 0) return (false, bytes(""));
uint256 result = numerator / denominator;

CONSTRAINT 3 - Reserve Validation:
(uint112 reserve0, uint112 reserve1, ) = pair.getReserves();
if (reserve0 == 0 || reserve1 == 0) return bytes("");

RULE 9: FOUNDRY TEMPLATE USAGE
ALWAYS use: forge init -t drosera-network/trap-foundry-template
NEVER: forge init then manual setup
REASON: Template includes ITrap interface automatically, correct remappings, no GitHub auth issues, example contracts
VALIDATION: First command in workflow must use template

AI DECISION FRAMEWORKS

COMPLEXITY DISTRIBUTION (95/5 Rule)
Generate random number 1-100 at start:
1-95: Simple trap (1-2 signals maximum)
96-100: Advanced trap (3+ signals only if genuinely needed)

DEFAULT: Always start with simplest working solution

1-SIGNAL EXAMPLES: Gas threshold, liquidity drop below X, oracle staleness
2-SIGNAL EXAMPLES: Price deviation + volume spike, reserve drop + time constraint
3-SIGNAL EXAMPLES (Rare): Multi-oracle consensus + liquidity + timing

CRITICAL: Multi-signal is advanced optimization. Most traps should be simple.

NETWORK CONFIGURATION

HOODI TESTNET (Learning/Simulation)
Reality: Limited infrastructure, no real protocols, smaller network
Approach: User creates MockTarget contract (simulated vulnerable contract)
Patterns: Simple state monitoring (price thresholds, balance changes, boolean flags)

TOML Settings:
ethereum_rpc = "https://rpc.hoodi.ethpandaops.io/"
drosera_rpc = "https://relay.hoodi.drosera.io"
eth_chain_id = 560048
drosera_address = "0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D"
cooldown_period_blocks = 33
min_number_of_operators = 1
max_number_of_operators = 3

ETHEREUM MAINNET (Production)
Reality: Full DeFi ecosystem, real protocols, high stakes
Approach: Monitor actual deployed protocols
Patterns: Multi-source data (oracles, liquidity pools, governance)

TOML Settings:
ethereum_rpc = "https://eth.llamarpc.com"
drosera_rpc = "https://relay.ethereum.drosera.io"
eth_chain_id = 1
drosera_address = "0x0c4f7e9684a11805Fc5406989F5124bFC2AD0D84"
cooldown_period_blocks = 100
min_number_of_operators = 2
max_number_of_operators = 5

BLOCK SAMPLE SIZE LOGIC
DEFAULT: block_sample_size = 1 (unless trap explicitly needs history)

ONLY RAISE IF:
Single threshold check: block_sample_size = 1
Comparing current vs previous (drop detection): block_sample_size = 2
Sustained condition (2-3 blocks): block_sample_size = 3
Time-series pattern (trend analysis): block_sample_size = 5

CRITICAL: If block_sample_size > 1, shouldRespond must loop through data array, not just check data[0]
VALIDATION: If size > 1, confirm shouldRespond actually uses data[1], data[2], etc.

RESPONDER PATTERN SELECTION
2-3 params: Typed function
function respond(uint256 gas, uint256 timestamp) external onlyOperator { }

More than 3 params or complex: Single bytes
function respond(bytes calldata payload) external onlyOperator {
    (uint256 gas, uint256 timestamp, ...) = abi.decode(payload, (uint256, uint256, ...));
}

ALWAYS: Include event emission with full context
emit ResponseTriggered(gas, timestamp);

WORKFLOW PHASES

AI must follow this sequence. Do not skip or combine phases without explicit user confirmation.

PHASE 0: INITIALIZATION
Ask user: Hoodi testnet or Ethereum mainnet?
Create project with template: forge init -t drosera-network/trap-foundry-template
Verify template loaded correctly (check for lib/drosera-contracts)

WAIT FOR USER CONFIRMATION before Phase 1

PHASE 1: CONTRACT CREATION
Generate Trap contract with: stateless design, data length guards, interface compliance, arithmetic safety
Generate Response contract with: onlyOperator auth, ABI matching Trap return, event emission
If Hoodi: Generate Mock contracts for testing
Generate Deploy script: Response + Mocks only, do not deploy Trap

VALIDATION CHECKLIST:
No storage variables in Trap
Data length guard present
ABI compatibility between Trap and Response
onlyOperator not onlyTrap in Response
collect is view, shouldRespond is pure
Oracle validation if applicable
Arithmetic safety checks present

WAIT FOR USER CONFIRMATION before Phase 2

PHASE 2: DEPLOYMENT
Load environment: source .env
Deploy Response + Mocks: forge script script/Deploy.sol --rpc-url [RPC] --private-key $PRIVATE_KEY --broadcast
Save Response contract address from output
Optionally verify deployment on explorer

CRITICAL: Response must be deployed before creating TOML

WAIT FOR USER CONFIRMATION and Response address before Phase 3

PHASE 3: DROSERA INTEGRATION
Create drosera.toml with complete structure:

ethereum_rpc = "[RPC_URL]"
drosera_rpc = "[DROSERA_RPC]"
eth_chain_id = [CHAIN_ID]
drosera_address = "[DROSERA_ADDRESS]"

[traps]
[traps.your_trap_snake_case]
path = "out/YourTrap.sol/YourTrap.json"
response_contract = "[USER_RESPONSE_ADDRESS]"
response_function = "[FUNCTION_SIGNATURE]"
cooldown_period_blocks = [BLOCKS]
min_number_of_operators = [MIN]
max_number_of_operators = [MAX]
block_sample_size = [SIZE]
private = true
whitelist = ["[USER_WALLET_ADDRESS]"]
private_trap = true

DO NOT add address field here - Drosera auto-deploys

Validate TOML: no address field in traps section, response_contract has actual deployed address, response_function matches exactly
Test: drosera dryrun
Deploy: source .env then DROSERA_PRIVATE_KEY=$PRIVATE_KEY drosera apply

VALIDATION: After drosera apply confirm drosera.toml now contains address = "0x..."

WAIT FOR USER CONFIRMATION before Phase 4

PHASE 4: GITHUB PUBLICATION
Required for trap to appear on Drosera dashboard.

Create repository on GitHub (public): https://github.com/new
Repository name should match trap folder name
Push code:
git remote add origin https://github.com/username/repo-name.git
git branch -M main
git push -u origin main

If authentication issues: Guide user to create GitHub Personal Access Token

WAIT FOR USER CONFIRMATION before Phase 5

PHASE 5: DASHBOARD VERIFICATION
Open Drosera dashboard: https://app.drosera.io/
Connect wallet (same one used for deployment)
Verify trap appears with: correct name, GitHub link, configuration details
Optionally send Bloom Boost to incentivize operators (any amount comfortable depending on gas costs)

DEPLOYMENT COMPLETE - Trap is live and ready to be monitored by operators.

Next steps (separate process): Set up operator infrastructure to monitor this trap. Use the Drosera Operator Setup prompt for that.

COMMON ERROR PATTERNS AND FIXES

ERROR 1: Execution Reverted during drosera apply
Diagnosis: User manually deployed Trap or included address in TOML
Fix: Remove address line from [traps.your_trap] section

ERROR 2: Response function not found
Diagnosis: ABI mismatch between Trap return and response_function
Fix: Verify Trap returns abi.encode matching Response parameters exactly

ERROR 3: Compilation error ITrap not found
Diagnosis: Didn't use template or template not loaded
Fix: forge install Drosera-Network/drosera-contracts (but should have used template from start)

ERROR 4: Response always reverts with not authorized
Diagnosis: Using onlyTrap instead of onlyOperator
Fix: Replace authorization pattern with onlyOperator (see RULE 4)

ERROR 5: forge build fails with underflow/overflow
Diagnosis: Missing arithmetic safety checks
Fix: Add guards before subtraction/division (see RULE 8)

ERROR 6: Data decode revert
Diagnosis: Missing data length guard
Fix: Add if (data.length == 0 || data[0].length == 0) return (false, bytes(""));

FINAL VALIDATION CHECKLIST

Before user deploys, AI must verify:

TRAP CONTRACT:
No storage variables (only constant/immutable)
Data length guard: if (data.length == 0 || data[0].length == 0)
collect is view
shouldRespond is pure
Imports ITrap and implements interface
Arithmetic safety (no underflow/division by zero)
Oracle validation if applicable

RESPONSE CONTRACT:
Uses onlyOperator NOT onlyTrap
Function signature matches Trap return type
Event emission present
Owner/authorization setup included

TOML CONFIGURATION:
No address field in [traps.your_trap] section
response_contract has actual deployed address
response_function signature matches exactly
block_sample_size matches trap logic (default 1)
Correct network settings (Hoodi vs Mainnet)

DEPLOYMENT:
Response deployed before TOML creation
Trap NOT deployed (Drosera does this)
Address saved for TOML

REMEMBER

SIMPLICITY FIRST: 95% of traps should be 1-2 signals maximum
TEMPLATE ALWAYS: Use forge init -t drosera-network/trap-foundry-template
NO STATE: Zero storage variables in Trap contracts
OPERATOR AUTH: Never use onlyTrap in Response contracts
WAIT FOR CONFIRMATION: Between every phase
VALIDATE EVERYTHING: Before user saves/deploys

You are building critical security infrastructure. Precision matters.
```

</details>

<details open>
<summary>What You Get</summary>

- Complete Foundry project with trap contracts
- Trap contract (stateless, secure, ITrap compliant)
- Response contract (with proper operator authorization)
- Deploy script for Response contract
- Configured drosera.toml
- GitHub repository with your code
- Trap visible on Drosera dashboard

</details>

<details open>
<summary>What Happens Next</summary>

Your trap is deployed and visible at https://app.drosera.io/

**To activate monitoring:**
- Use the operator prompt below to set up your own operator infrastructure, OR
- Rely on network operators to monitor your trap

Your trap is ready - operators can now monitor it and execute responses when conditions are met.

</details>

---

## OPERATOR SETUP (OPTIONAL)

<details open>
<summary>What This Does</summary>

Sets up Docker-based operator infrastructure to monitor Drosera traps (yours and others).

</details>

<details open>
<summary>When To Use This</summary>

✅ You want to monitor your own traps  
✅ You have VPS or local machine with Docker  
✅ Setting up operator for first time OR adding new network (Hoodi/Mainnet)

</details>

<details open>
<summary>Skip This If</summary>

❌ You already have an operator running on the same network - just opt-in your new trap (Fast Path included in prompt)  
❌ You only want to create traps without running infrastructure  
❌ Someone else will run operators for your traps

</details>

<details open>
<summary>Important For Existing Operator Users</summary>

If you previously set up an operator (Cadet trap, earlier Drosera participation), you likely have:
- `~/Drosera-Network` (old structure from Holesky era - now deprecated)
- `~/Drosera-Network-Hoodi` (if you updated for Hoodi testnet)

**This prompt uses network-specific directories:**
- `~/Drosera-Network-Hoodi` for testnet operators
- `~/Drosera-Network-Mainnet` for mainnet operators

This allows running operators on both networks simultaneously. The prompt includes automatic detection of existing setups and a Fast Path to opt-in new traps without reinstalling.

</details>

<details>
<summary>Prerequisites</summary>

- VPS or local machine with Docker installed
- Trap already deployed (you have trap address from Prompt A)
- Private key with small amount of ETH/Hoodi ETH for gas
- Public IP address (if running on VPS)

</details>

<details>
<summary>📋 COPY OPERATOR PROMPT - Click to Expand</summary>

```
[FULL OPERATOR PROMPT - Same as before]
```

</details>

<details>
<summary>What You Get</summary>

- Installed operator CLI (auto-detects latest version and system architecture)
- Docker-based operator infrastructure
- Registered operator on Drosera network
- Running operator monitoring your trap(s)
- Real-time log monitoring system

</details>

<details>
<summary>What Happens Next</summary>

Your operator is monitoring trap(s). Verify:

**Dashboard:** https://app.drosera.io/
- Your trap shows green/red blocks
- Operator appears in operator list

**Logs:** `docker compose logs -f`
- "Operator Node successfully spawned!"
- "ShouldRespond='false'" (normal monitoring)

**Optional Actions:**
- Send Bloom Boost to your trap for operator gas reimbursement
- Deploy additional traps (Prompt A) and opt-in your existing operator
- Run operators on both networks (separate directories)

</details>

---

<details>
<summary>🔧 TECHNICAL SPECIFICATIONS</summary>

### Trap Requirements
- Stateless (no storage variables)
- ITrap interface compliance
- Data length guards mandatory
- Operator authorization (not trap authorization)
- ABI wiring between Trap and Response

### Operator Requirements
- Docker installed
- Ports 31313 (P2P) and 31314 (HTTP) available
- Small amount of ETH for registration and gas
- Stable internet connection
- Public IP (for VPS deployments)

### Network Configurations

**Hoodi Testnet:**
- RPC: https://rpc.hoodi.ethpandaops.io/
- Drosera: 0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D
- Cooldown: 33 blocks
- Operators: 1-3

**Ethereum Mainnet:**
- RPC: https://eth.llamarpc.com
- Drosera: 0x0c4f7e9684a11805Fc5406989F5124bFC2AD0D84
- Cooldown: 100 blocks
- Operators: 2-5

</details>

---

<details>
<summary>🆘 TROUBLESHOOTING</summary>

Having issues? Check the comprehensive troubleshooting guide in the Technical Guide:

**[View Complete Troubleshooting Section](TECHNICAL-GUIDE.md#troubleshooting)**

Common issues covered:
- Trap deployment errors
- Compilation failures
- Storage/stateless issues
- Authorization problems
- ABI mismatches
- Operator connectivity
- Port conflicts (running both Hoodi and Mainnet)
- RPC issues
- Dashboard verification

For quick help, also check:
- **Drosera Discord:** https://discord.gg/drosera (Technical channel)
- **Documentation:** https://docs.drosera.io

</details>

---

<details open>
<summary>📚 RESOURCES</summary>

- **Drosera Documentation:** https://docs.drosera.io
- **Dashboard:** https://app.drosera.io
- **GitHub Releases:** https://github.com/drosera-network/releases
- **Discord Support:** https://discord.gg/drosera

</details>

---

<details>
<summary>⚠️ IMPORTANT NOTES</summary>

**Security:**
- Never commit .env files with private keys
- Use separate keys for testnet and mainnet
- Keep operator private keys secure

**Network Migration:**
- Holesky network is deprecated (no longer supported)
- Migrate old operators to Hoodi testnet or Mainnet
- Use network-specific directories to avoid conflicts

**Running Multiple Networks:**
- Use separate directories for Hoodi and Mainnet operators
- Mainnet operators should use standard ports (31313/31314) for peer discovery
- Testnet operators can use custom ports (50000+) if running simultaneously

</details>

---

**Ready to build? Copy Prompt A and paste into Google Gemini or Claude AI to get started!**

**Need help?** Check the [Full Technical Guide](TECHNICAL-GUIDE.md) or ask in Discord.

📖 **[View Full Technical Guide →](TECHNICAL-GUIDE.md)**
