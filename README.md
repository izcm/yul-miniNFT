# Mini721 🐥

I wanted to understand the EVM on an opcode level and found that implementing an ultra-minimal ERC721 was a fun way to do exactly that. 🚀

---

## Deploy Mini on Anvil

```bash
cast send \
--rpc-url http://127.0.0.1:8545 \
--private-key 0xYOURPRIVATEKEY \
--legacy \
--create "0x335f55601c600e5f39601c5ff3fe60056014565b6340c10f19146012575f80fd5b005b5f3560e01c9056"
```

## Test the Mini with Foundry

```bash
    mkdir -p data && solc --strict-assembly yul/Mini721.yul --bin > data/Mini721.bin
```
