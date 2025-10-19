// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

/**
 * @title ExampleTrap
 * @notice A simple example trap that monitors gas price spikes
 * @dev This is a reference template - create your own unique logic
 */
contract ExampleTrap is ITrap {
    // Threshold: 50 gwei
    uint256 public constant GAS_THRESHOLD = 50 gwei;
    
    /**
     * @notice Collects current gas price data
     * @return Encoded current block's base fee
     */
    function collect() external view override returns (bytes memory) {
        uint256 gasPrice = block.basefee;
        return abi.encode(gasPrice);
    }
    
    /**
     * @notice Checks if gas price exceeds threshold
     * @param data Encoded gas price from collect()
     * @return shouldTrigger True if gas > threshold
     * @return responseData Encoded gas price for response
     */
    function shouldRespond(bytes calldata data) 
        external 
        pure 
        override 
        returns (bool shouldTrigger, bytes memory responseData) 
    {
        uint256 gasPrice = abi.decode(data, (uint256));
        
        if (gasPrice > GAS_THRESHOLD) {
            return (true, abi.encode(gasPrice));
        }
        
        return (false, "");
    }
}
