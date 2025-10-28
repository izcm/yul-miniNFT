// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

contract Mini721Test is Test {
    address deployed;

    function setUp() public {
        // mini721's bytecode
        bytes memory bytecode =
            hex"335f55601c600e5f39601c5ff3fe60056014565b6340c10f19146012575f80fd5b005b5f3560e01c9056";

        // deploy it
        assembly {
            // point to bytecode
            let ptr := add(bytecode, 0x20)
            let size := mload(bytecode)

            // call create & save address returned from constructor
            let addr := create(0, ptr, size)

            // revert if deployment faill
            if iszero(addr) { revert(0, 0) }

            // store the returned address in slot of `deployed`
            sstore(deployed.slot, addr)
        }

        console.log("Mini721 deployed at:  %s", deployed);
    }

    function test_ContractWasCreated() public view {
        assertTrue(true);
    }
}
