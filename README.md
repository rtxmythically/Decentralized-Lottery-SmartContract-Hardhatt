# Decentralized Lottery Smart Contract

This repository contains the **Solidity smart contract** for the Decentralized Lottery system.  
It is deployed on the **Ethereum Sepolia Testnet**, enabling users to participate in a fair and transparent on-chain lottery with an entry fee of **0.01 ETH**.

> **Frontend Application:**  
> [Decentralized Lottery DApp (React)](https://github.com/rtxmythically/decentralized-lottery)

> **Live DApp:**  
> [https://decentralized-lottery.web.app/](https://decentralized-lottery.web.app/)

---

## Overview

The contract implements a decentralized lottery mechanism using Solidity.  
Participants can join by paying a fixed entry fee, and once the conditions are met, the contract selects a random winner who can withdraw the prize pool.  
All transactions and states are stored on-chain, ensuring full transparency and immutability.

---

## Contract Details

- **Network:** Ethereum Sepolia Testnet  
- **Contract Address:** `0x9FDBBBeda4495fc63A2E90886D6EDeFf52343233`  
- **Entry Fee:** `0.01 ETH`  
- **Language:** Solidity  
- **Framework:** Hardhat  

---

## Features

- Fully decentralized, transparent lottery logic  
- Fixed entry fee (0.01 ETH)  
- Winner selection by pseudo-random number generation  
- Automatic fund transfer to the winner  
- Easy integration with frontends via **Ethers.js**  
- Future support for **Chainlink VRF** (verifiable randomness)
