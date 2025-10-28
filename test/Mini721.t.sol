// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

contract Mini721Test is Test {
    // mini721's bytecode
    bytes bytecode = hex"335f55601c600e5f39601c5ff3fe60056014565b6340c10f19146012575f80fd5b005b5f3560e01c9056";

    // mini's storage memory layout
    uint256 slotOwner = 0x00;
    uint256 slotTotalSupply = 0x01;

    address deployed;

    function setUp() public {
        // copy storage -> memory
        bytes memory bc = bytecode;

        assembly {
            // memory slot 0x00 => 0x31F contains bc size
            let size := mload(bc)
            // bc data 0x20 => bc.size
            let ptr := add(bc, 0x20)

            // call create & save address returned from constructor
            let addr := create(0, ptr, size)

            // revert if deployment faill
            if iszero(addr) { revert(0, 0) }

            // store the returned address in slot of `deployed`
            sstore(deployed.slot, addr)
        }

        console.log("Mini721 deployed at:  %s", deployed);
    }

    // -----------------------
    // DEPLOYMENT
    // -----------------------
    /*function test_RuntimeCodeIsDeployedCorrectly() external view {
        // we need to get the bc stored in the world state...
        // and we do this by fetching the bytecode and compare it to ours
        assertTrue(true);
        console.log(vm.toString(deployed.bc));

        assertContains()
    }*/

    function test_OwnerIsSetToDeployer() external view {
        uint256 value = loadSlotValue(deployed, slotOwner);
        address deployer = address(uint160(value));

        assertEq(deployer, address(this));
    }

    function test_TotalSupplyStartsAtZero() external view {
        uint256 totalSupply = loadSlotValue(deployed, slotTotalSupply);
        assertEq(totalSupply, 0);
    }

    function test_IncrementsTotalSupply() external view {
        assertTrue(true);
    }

    // -----------------------
    // MINTING
    // -----------------------

    // -----------------------
    // 🔧 PRIVATE HELPERS
    // -----------------------
    function loadSlotValue(address account, uint256 slot) private view returns (uint256) {
        bytes32 value = vm.load(account, bytes32(slot));
        return uint256(value);
    }

    // to isolate the runtime from the creationcode
    //  1. get the offset by getting the position of 0xf3 RETURN opcode
    //  2.
    function extractRuntime(bytes memory creation) internal pure returns (bytes memory) {
        uint256 offset; // position of runtime
    }
}
