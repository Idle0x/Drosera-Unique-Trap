// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ExampleResponse
 * @notice Handles responses when trap triggers
 * @dev This is a reference template - customize for your needs
 */
contract ExampleResponse {
    event GasSpikeDetected(uint256 gasPrice, uint256 timestamp, address caller);
    
    address public trapConfig;
    
    constructor(address _trapConfig) {
        trapConfig = _trapConfig;
    }
    
    modifier onlyTrapConfig() {
        require(msg.sender == trapConfig, "Only TrapConfig");
        _;
    }
    
    /**
     * @notice Called when gas spike is detected
     * @param gasPrice The gas price that triggered the alert
     */
    function handleGasSpike(uint256 gasPrice) external onlyTrapConfig {
        emit GasSpikeDetected(gasPrice, block.timestamp, msg.sender);
    }
}
