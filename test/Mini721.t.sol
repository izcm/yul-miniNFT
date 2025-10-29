// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

contract Mini721Test is Test {
    // mini721's bytecode
    bytes bytecode = hex"335f556080600e5f3960805ff3fe6005606e565b636a627842146012575f80fd5b60043560601c8015602657602490602a565b005b5f80fd5b60306076565b54908082603a607b565b01556001820160466076565b555f7fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef8180a4565b5f3560e01c90565b600190565b60109056";

    // mini's storage memory layout
    uint256 slotOwner = 0x00;
    uint256 slotTotalSupply = 0x01;

    address deployed;
    address user;

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
        user = makeAddr("user");

        // copy storage -> memory
        bytes memory creation = bytecode;

        assembly {
            // memory slot 0x00 => 0x31F contains bc length
            let size := mload(creation)
            // bc data 0x20 => bc.size
            let ptr := add(creation, 0x20)

            // call create & save address returned from constructor
            let addr := create(0, ptr, size)

            // revert if deployment failed
            if iszero(addr) { revert(0, 0) }

            // store the returned address in slot of `deployed`
            sstore(deployed.slot, addr)
        }

        console.log("Mini721 deployed at:  %s", deployed);
        runtimeCodeIsDeployedCorrectly();
    }

    /**
     * @dev Ensures the deployed Mini721 contract actually matches
     * the runtime compiled from `Mini721.yul`.
     *
     * This doesn’t test contract logic — it catches setup or deployment
     * issues (e.g. wrong byte offsets, truncated code, or bad CREATE params).
     */
    function runtimeCodeIsDeployedCorrectly() internal view {
        bytes memory creation = bytecode;

        uint256 pos = bytePosition(creation, bytes1(0xfe)); // 0xfe
        bytes memory runtime = new bytes(creation.length - (pos + 1));

        for (uint256 i = 0; i < runtime.length; i++) {
            runtime[i] = creation[i + pos + 1];
        }

        assertEq(runtime, deployed.code);
    }

    // -----------------------
    // DEPLOYMENT
    // -----------------------
    function test_OwnerIsSetToDeployer() external view {
        uint256 value = loadSlotValue(deployed, slotOwner);
        address deployer = address(uint160(value));

        assertEq(deployer, address(this));
    }

    function test_TotalSupplyStartsAtZero() external view {
        uint256 totalSupply = loadSlotValue(deployed, slotTotalSupply);
        assertEq(totalSupply, 0);
    }

    // -----------------------
    // MINTING
    // -----------------------
    function test_MintingIncrementsTotalSupply() external {
        uint256 supplyBefore = loadSlotValue(deployed, slotTotalSupply);
        
        (bool ok, ) = 
            deployed.call(bytes.concat(hex"6a627842", bytes32(uint256(uint160(user)))));
        require(ok, "call failed");

        uint256 supplyAfter = loadSlotValue(deployed, slotTotalSupply);
        assertEq(supplyBefore + 1, supplyAfter);
    }

    // -----------------------
    // 🔧 PRIVATE HELPERS
    // -----------------------
    function loadSlotValue(address account, uint256 slot) private view returns (uint256) {
        bytes32 value = vm.load(account, bytes32(slot));
        return uint256(value);
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
}
