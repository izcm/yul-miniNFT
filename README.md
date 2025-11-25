# MiniNFT 🐥

**⚠️ DISCLAIMER: This NFT is only for educational purposes only. It is not ERC-721 compliant, not production-ready, and not intended for wallet or marketplace support**

I wanted to understand the EVM on an opcode level and found that implementing an NFT was a fun way to do exactly that. 🚀

This NFT is not ERC-721 compliant, but it is a non-fungable token. Some educational stuff like bitpacking NFT specs into the `ownerOf` mapping makes this NFT implementation kind of wild, perfect for _play and learn_.

✅ It **mints**, **tracks ownership**, and **emits events**
❌ It does **not follow the ERC-721 spec**
🎯 It exists purely as a playground to learn low-level EVM, storage, and gas behavior

---

## 🖼️ Setup

```bash
cast abi-decode "svg()(string)" $(cast call <CONTRACT_ADDR> "svg()" --rpc-url <RPC_URL>) > output.svg
```

Now open `output.svg` in any browser or image viewer.

---

### 🛠 Available Make Commands

| Command            | Description                                            |
| ------------------ | ------------------------------------------------------ |
| `make build`       | Compile the Yul contract → outputs raw bytecode (.bin) |
| `make deploy`      | Deploy via Foundry script (`DeployMini721.s.sol`)      |
| `make mint`        | Mint a token to `USER_ADDR` (from `.env`)              |
| `make totalSupply` | Read the on-chain total supply                         |
| `make fork-anvil`  | Start an Anvil mainnet fork (for testing)              |
| `make clean`       | Remove build artifacts                                 |

✅ All variables (`RPC_URL`, `PRIVATE_KEY`, `CONTRACT_ADDR`, `USER_ADDR`, etc.) are loaded from `.env`.

---

#### If `.env` already has everything:

```
RPC_URL=http://127.0.0.1:8545
PRIVATE_KEY=0x...
CONTRACT_ADDR=0x...
USER_ADDR=0x...
```

then you can just run:

```
make deploy
make mint
make totalSupply
```

---

## Features

### 🚨 Error Handling

This demo mentions two common revert styles in EVM development:

#### 1. **Custom Errors (selector-only)**

- ABI sends only a 4-byte selector (e.g. `InvalidToken()`).
- No offset, no dynamic data, no padding.
- Low gas cost, easy to decode in Foundry/Viem.
- Preferred in modern protocol design.

Yul structure:

```
mstore(ptr, shl(224, selector))
revert(ptr, 0x04)
```

---

#### 2. **Classic `Error(string)`**

- ABI encodes the full message:
  selector → offset → length → bytes → padding.
- More expensive, but beginner-friendly and descriptive.
- The style used by early Solidity patterns / require().

Yul structure:

```
mstore(ptr, shl(224, 0x08c379a0))  // Error(string)
...
revert(ptr, totalSize)
```

---

> MiniNFT uses **custom errors only**, but both styles are shown conceptually so students understand how revert payloads differ on the ABI level.

---
