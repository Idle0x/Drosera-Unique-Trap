// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {ExampleTrap} from "../src/ExampleTrap.sol";
import {ExampleResponse} from "../src/ExampleResponse.sol";

/**
 * @title Deploy
 * @notice Deployment script for trap and response contracts
 * @dev Run with: forge script script/Deploy.sol --rpc-url <url> --private-key <key> --broadcast
 */
contract Deploy is Script {
    function run() external {
        vm.startBroadcast();
        
        // Deploy trap (no constructor args)
        ExampleTrap trap = new ExampleTrap();
        console.log("Trap deployed at:", address(trap));
        
        // Deploy response with trap address
        ExampleResponse response = new ExampleResponse(address(trap));
        console.log("Response deployed at:", address(response));
        
        vm.stopBroadcast();
    }
}
