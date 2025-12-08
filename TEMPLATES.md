# Configuration Templates & Examples

Quick reference for configuration files and contract templates.

---

## Configuration Files

### foundry.toml

```toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
solc = "0.8.20"
```

### remappings.txt

```
drosera-contracts/=lib/drosera-contracts/
forge-std/=lib/forge-std/src/
openzeppelin-contracts/=lib/openzeppelin-contracts/
@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/
ds-test/=lib/openzeppelin-contracts/lib/forge-std/lib/ds-test/src/
erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/
halmos-cheatcodes/=lib/openzeppelin-contracts/lib/halmos-cheatcodes/src/
```

### .env Template

```bash
PRIVATE_KEY=0xYOUR_PRIVATE_KEY_HERE
GITHUB_TOKEN=YOUR_GITHUB_TOKEN_HERE
```

### .gitignore

```
.env
out/
cache/
broadcast/
lib/
node_modules/
```

---

## drosera.toml Templates

### Hoodi Testnet Configuration

```toml
ethereum_rpc = "https://rpc.hoodi.ethpandaops.io/"
drosera_rpc = "https://relay.hoodi.drosera.io"
eth_chain_id = 560048
drosera_address = "0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D"

[traps]
[traps.your_trap_name]
path = "out/YourTrap.sol/YourTrap.json"
response_contract = "0xYOUR_RESPONSE_CONTRACT_ADDRESS"
response_function = "respond(address,uint256)"
cooldown_period_blocks = 33
min_number_of_operators = 1
max_number_of_operators = 3
block_sample_size = 10
private = true
whitelist = ["0xYOUR_WALLET_ADDRESS"]
private_trap = true
# Drosera will auto-fill: address = "0x..."
```

### Ethereum Mainnet Configuration

```toml
ethereum_rpc = "https://eth.llamarpc.com"
drosera_rpc = "https://relay.mainnet.drosera.io"
eth_chain_id = 1
drosera_address = "0x0c4f7e9684a11805Fc5406989F5124bFC2AD0D84"

[traps]
[traps.your_trap_name]
path = "out/YourTrap.sol/YourTrap.json"
response_contract = "0xYOUR_RESPONSE_CONTRACT_ADDRESS"
response_function = "respond(address,uint256)"
cooldown_period_blocks = 100
min_number_of_operators = 2
max_number_of_operators = 5
block_sample_size = 20
private = true
whitelist = ["0xYOUR_WALLET_ADDRESS"]
private_trap = true
# Drosera will auto-fill: address = "0x..."
```

---

## Contract Templates

### ITrap Interface

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITrap {
    function collect() external view returns (bytes memory);
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory);
}
```

---

## Example: Simulated Testnet Trap

For Hoodi testnet learning purposes.

### SimulatedPriceDeviationTrap.sol

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "drosera-contracts/interfaces/ITrap.sol";

/**
 * @title Simulated Price Deviation Trap (Testnet Learning Template)
 * @notice This trap simulates monitoring price deviations between two sources.
 * @dev Uses internal state variables since Hoodi testnet lacks reliable external contracts.
 * 
 * How to test:
 * 1. Deploy this trap via Drosera
 * 2. Call updateSimulatedPrices() to change the state
 * 3. Observe how shouldRespond() evaluates the deviation
 */
contract SimulatedPriceDeviationTrap is ITrap {
    // Simulated state variables
    uint256 public simulatedOraclePrice = 2000e18; // $2000
    uint256 public simulatedDexPrice = 2000e18;    // $2000
    uint256 public simulatedVolume = 100e18;       // 100 tokens
    
    uint256 public constant DEVIATION_THRESHOLD = 5; // 5%
    uint256 public constant VOLUME_THRESHOLD = 1000e18; // 1000 tokens
    
    /**
     * @notice Helper function to update simulated prices for testing
     * @dev Call this to test different scenarios
     */
    function updateSimulatedPrices(
        uint256 _oraclePrice,
        uint256 _dexPrice,
        uint256 _volume
    ) external {
        simulatedOraclePrice = _oraclePrice;
        simulatedDexPrice = _dexPrice;
        simulatedVolume = _volume;
    }
    
    /**
     * @notice Collects simulated monitoring data
     * @dev Reads internal state variables instead of external contracts
     */
    function collect() external view returns (bytes memory) {
        return abi.encode(
            simulatedOraclePrice,
            simulatedDexPrice,
            simulatedVolume,
            block.timestamp
        );
    }
    
    /**
     * @notice Evaluates if the trap should trigger
     * @dev Returns true if price deviation >5% AND volume >1000 tokens
     */
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
        if (data.length == 0) return (false, "");
        
        (
            uint256 oraclePrice,
            uint256 dexPrice,
            uint256 volume,
        ) = abi.decode(data[0], (uint256, uint256, uint256, uint256));
        
        // Calculate deviation percentage
        uint256 diff = oraclePrice > dexPrice 
            ? oraclePrice - dexPrice 
            : dexPrice - oraclePrice;
        uint256 deviationPercent = (diff * 100) / oraclePrice;
        
        // Check both conditions (multivector)
        bool significantDeviation = deviationPercent >= DEVIATION_THRESHOLD;
        bool highVolume = volume >= VOLUME_THRESHOLD;
        
        if (significantDeviation && highVolume) {
            return (
                true, 
                abi.encode(oraclePrice, dexPrice, deviationPercent, volume)
            );
        }
        
        return (false, "");
    }
}
```

### SimulatedPriceDeviationResponse.sol

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimulatedPriceDeviationResponse {
    event PriceDeviationDetected(
        uint256 oraclePrice,
        uint256 dexPrice,
        uint256 deviationPercent,
        uint256 volume,
        uint256 timestamp
    );
    
    function respond(
        uint256 oraclePrice,
        uint256 dexPrice,
        uint256 deviationPercent,
        uint256 volume
    ) external {
        emit PriceDeviationDetected(
            oraclePrice,
            dexPrice,
            deviationPercent,
            volume,
            block.timestamp
        );
    }
}
```

---

## Example: Production Mainnet Trap

For Ethereum mainnet real monitoring.

### LiquidityDrainTrap.sol

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "drosera-contracts/interfaces/ITrap.sol";

interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns (address);
    function token1() external view returns (address);
}

/**
 * @title Liquidity Drain Detection Trap (Production Mainnet)
 * @notice Monitors Uniswap V2 pool for sudden liquidity drains
 * @dev Triggers when reserves drop >30% within 10 blocks
 * 
 * Why this is valuable:
 * - Detects potential rug pulls or coordinated attacks
 * - Monitors real economic activity
 * - Quiet by default (only triggers on significant events)
 * - Protects users by detecting suspicious liquidity movements
 */
contract LiquidityDrainTrap is ITrap {
    IUniswapV2Pair public immutable monitoredPair;
    
    uint256 public constant DRAIN_THRESHOLD = 30; // 30% drop
    uint256 public constant TIME_WINDOW = 10; // blocks
    
    constructor(address _pairAddress) {
        monitoredPair = IUniswapV2Pair(_pairAddress);
    }
    
    /**
     * @notice Collects current reserve data from the pool
     * @dev Called by Drosera operators on each monitoring cycle
     */
    function collect() external view returns (bytes memory) {
        (uint112 reserve0, uint112 reserve1, uint32 timestamp) = monitoredPair.getReserves();
        
        return abi.encode(
            reserve0,
            reserve1,
            block.number,
            timestamp,
            monitoredPair.token0(),
            monitoredPair.token1()
        );
    }
    
    /**
     * @notice Evaluates if liquidity drain occurred
     * @dev Compares current reserves to previous data points
     * @return shouldTrigger True if drain detected
     * @return payload Data to pass to response contract
     */
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
        if (data.length < 2) return (false, "");
        
        // Decode current and previous data
        (
            uint112 oldReserve0,
            uint112 oldReserve1,
            uint256 oldBlock,
            ,
            address token0,
            address token1
        ) = abi.decode(data[0], (uint112, uint112, uint256, uint32, address, address));
        
        (
            uint112 newReserve0,
            uint112 newReserve1,
            uint256 newBlock,
            ,
            ,
        ) = abi.decode(data[1], (uint112, uint112, uint256, uint32, address, address));
        
        // Calculate reserve changes
        uint256 reserve0Drop = oldReserve0 > newReserve0 
            ? ((oldReserve0 - newReserve0) * 100) / oldReserve0 
            : 0;
        uint256 reserve1Drop = oldReserve1 > newReserve1 
            ? ((oldReserve1 - newReserve1) * 100) / oldReserve1 
            : 0;
        
        uint256 blockDelta = newBlock - oldBlock;
        
        // Check if significant drain in short time window (multivector)
        bool significantDrain = reserve0Drop >= DRAIN_THRESHOLD || reserve1Drop >= DRAIN_THRESHOLD;
        bool recentDrain = blockDelta <= TIME_WINDOW;
        
        if (significantDrain && recentDrain) {
            return (
                true,
                abi.encode(
                    token0,
                    token1,
                    oldReserve0,
                    newReserve0,
                    oldReserve1,
                    newReserve1,
                    reserve0Drop,
                    reserve1Drop,
                    blockDelta
                )
            );
        }
        
        return (false, "");
    }
}
```

### LiquidityDrainResponse.sol

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LiquidityDrainResponse {
    event LiquidityDrainDetected(
        address indexed token0,
        address indexed token1,
        uint256 oldReserve0,
        uint256 newReserve0,
        uint256 oldReserve1,
        uint256 newReserve1,
        uint256 reserve0DropPercent,
        uint256 reserve1DropPercent,
        uint256 blockDelta,
        uint256 timestamp
    );
    
    function respond(
        address token0,
        address token1,
        uint256 oldReserve0,
        uint256 newReserve0,
        uint256 oldReserve1,
        uint256 newReserve1,
        uint256 reserve0Drop,
        uint256 reserve1Drop,
        uint256 blockDelta
    ) external {
        emit LiquidityDrainDetected(
            token0,
            token1,
            oldReserve0,
            newReserve0,
            oldReserve1,
            newReserve1,
            reserve0Drop,
            reserve1Drop,
            blockDelta,
            block.timestamp
        );
        
        // Additional response logic could include:
        // - Pausing related contracts (if permissions exist)
        // - Notifying governance
        // - Triggering insurance mechanisms
    }
}
```

---

## Deploy Script Template

**CRITICAL: Only deploys Response contract!**

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
        
        console.log("Response contract deployed at:", address(response));
        
        // DO NOT deploy Trap contract here!
        // Drosera will deploy it automatically via `drosera apply`
        
        vm.stopBroadcast();
    }
}
```

---

## Quick Command Reference

### Foundry Commands

```bash
# Initialize project
forge init

# Install dependencies
forge install foundry-rs/forge-std@v1.8.2
forge install OpenZeppelin/openzeppelin-contracts@v5.0.2

# Compile contracts
forge build

# Deploy script (testnet)
forge script script/Deploy.sol \
  --rpc-url https://rpc.hoodi.ethpandaops.io \
  --private-key $PRIVATE_KEY \
  --broadcast

# Deploy script (mainnet)
forge script script/Deploy.sol \
  --rpc-url https://eth.llamarpc.com \
  --private-key $PRIVATE_KEY \
  --broadcast
```

### Drosera Commands

```bash
# Test configuration
drosera dryrun

# Deploy trap to network
DROSERA_PRIVATE_KEY=your_key drosera apply

# Check operator status
systemctl status drosera-operator
```

### Git Commands

```bash
# Initialize repository
git init
git add .
git commit -m "Initial commit"

# Push to GitHub
git remote add origin https://USERNAME:TOKEN@github.com/USERNAME/repo.git
git branch -M main
git push -u origin main
```

---

## Network Reference

### Hoodi Testnet
- **RPC:** `https://rpc.hoodi.ethpandaops.io/`
- **Chain ID:** `560048`
- **Drosera Relay:** `https://relay.hoodi.drosera.io`
- **Drosera Address:** `0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D`
- **Block Explorer:** [hoodi.ethpandaops.io](https://hoodi.ethpandaops.io)

### Ethereum Mainnet
- **RPC:** `https://eth.llamarpc.com`
- **Chain ID:** `1`
- **Drosera Relay:** `https://relay.mainnet.drosera.io`
- **Drosera Address:** `0x0c4f7e9684a11805Fc5406989F5124bFC2AD0D84`
- **Block Explorer:** [etherscan.io](https://etherscan.io)

---

## Additional Resources

- [Drosera Documentation](https://docs.drosera.io)
- [Foundry Book](https://book.getfoundry.sh)
- [Solidity Documentation](https://docs.soliditylang.org)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts)
