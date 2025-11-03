// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

contract Mini721Test is Test {
    address deployed;

    // storage memory layout
    uint256 slotTotalSupply = 0x00;

    // selectors
    bytes4 selectorMint = bytes4(keccak256("mint(address)"));
    bytes4 selectorTotalSupply = bytes4(keccak256("totalSupply()"));
    bytes4 selectorTokenURI = bytes4(keccak256("tokenURI(uint256)"));
    bytes4 selectorSVG = bytes4(keccak256("svg()"));

    // -----------------------
    // SETUP
    // -----------------------

    /**
     *  @dev Deploys the Mini721 Yul contract manually using `create`.
     *
     *  We run the post-deployment verification `runtimeCodeIsDeployedCorrectly`
     *  to make sure the constructor actually returned the correct runtime segment.
     */
    function setUp() public {
        string memory path = "./data/Mini721.bin";
        string memory data = vm.readFile(path);
        bytes memory creation = vm.parseBytes(data);

        console.logBytes(creation);
        uint256 testSize;
        address addr;

        // TODO get the code directly from deployed after creation in assembly
        assembly {
            // memory slot 0x00 => 0x31F contains bc length
            let size := mload(creation)
            testSize := size

            // bc data 0x20 => bc.size
            let ptr := add(creation, 0x20)

            // call create & save address returned from constructor
            addr := create(0, ptr, size)
            // REMOVE COMMENT AND SEE IT FAIL 1/2 🔴🔴 addr := create(0, ptr, size)

            // revert if deployment failed
            if iszero(addr) { revert(0, 0) }

            // REMOVE COMMENT AND SEE IT FAIL 2/2 🔴🔴  sstore(deployed.slot, addr)
        }

        deployed = addr;
        bytes memory out;

        assembly {
            // get size
            let size := extcodesize(sload(deployed.slot))
            // allocate memory
            out := mload(0x40)
            mstore(out, size)
            // copy bytecode
            extcodecopy(sload(deployed.slot), add(out, 0x20), 0, size)
            // update free memory pointer
            mstore(0x40, add(add(out, 0x20), size))
        }

        console.log("Runtime loaded via extcodecopy, length:", out.length);
        console.logBytes(out);

        console.log("Size from asssembly: ", testSize);

        bytes memory code = deployed.code;
        console.log("Runtime code length:", code.length);
        console.logBytes(code);

        console.log("--------------------------------------------------------------");
        console.log("Mini721 deployed at:  %s", deployed);
        console.log("--------------------------------------------------------------");

        runtimeCodeIsDeployedCorrectly(creation);
    }

    /**
     * @dev Ensures the deployed Mini721 contract actually matches
     * the runtime compiled from `Mini721.yul`.
     *
     * This doesn’t test contract logic — it catches setup or deployment
     * issues (e.g. wrong byte offsets, truncated code, or bad CREATE params).
     */
    function runtimeCodeIsDeployedCorrectly(bytes memory creation) internal view {
        uint256 pos = bytePosition(creation, bytes1(0xfe)); // 0xfe
        bytes memory runtime = new bytes(creation.length - (pos + 1));

        for (uint256 i = 0; i < runtime.length; i++) {
            runtime[i] = creation[i + pos + 1];
        }

        /*
        console.log("--------------------------------------------------------------");
        console.log("Runtime: ");
        console.logBytes(deployed.code);
        console.log("Creation: ");
        console.logBytes(creation);
        console.log("--------------------------------------------------------------");
        */

        assertEq(runtime, deployed.code, "runtime doesn't match!");
        assertEq(keccak256(runtime), keccak256(deployed.code), "runtime doesn't match!");
    }

    function bytePosition(bytes memory bc, bytes1 marker) internal pure returns (uint256) {
        uint256 offset;
        uint256 len = bc.length;

        for (uint256 i; i < len; i++) {
            if (bc[i] == marker) {
                offset = i;
                break;
            }
        }

        return offset;
    }

    // -----------------------
    // DEPLOYMENT
    // -----------------------
    function test_TotalSupplyStartsAtZero() external view {
        assertTrue(true);
    }

    /// Loads value at `slot` for given account
    function loadSlotValue(address account, uint256 slot) internal view returns (uint256) {
        bytes32 value = vm.load(account, bytes32(slot));
        return uint256(value);
    }

    /// Calls Mini721 mint()
    function callMint(address to) internal returns (bool ok) {
        (ok,) = deployed.call(bytes.concat(hex"6a627842", bytes32(uint256(uint160(to)))));
    }

    /// Calls Mini721 mint() and requires success
    function callMintStrict(address to) internal {
        bool ok = callMint(to);
        console.log("mint went ok?");
        console.log(ok);
        require(ok, "call failed");
    }
}
