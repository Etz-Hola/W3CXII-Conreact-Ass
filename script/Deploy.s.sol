// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/W3CXII.sol";

contract DeployScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy W3CXII contract with 0.5 ETH initial deposit
        W3CXII w3cxii = new W3CXII{value: 0.5 ether}();

        vm.stopBroadcast();
        console.log("W3CXII deployed to:", address(w3cxii));
    }
} 