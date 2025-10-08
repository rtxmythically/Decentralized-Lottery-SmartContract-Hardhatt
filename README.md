# 🎯 Decentralized Lottery Smart Contract

This repository contains the **smart contract layer** for the Decentralized Lottery DApp — a fully on-chain, transparent, and fair lottery system built with **Solidity** and **Hardhat**.

> 💡 The frontend DApp is available in a separate repository:  
> [Decentralized Lottery Frontend](https://github.com/rtxmythically/decentralized-lottery)

---

## 🚀 Overview

This smart contract implements a decentralized lottery where participants can enter by paying an entry fee.  
When specific conditions are met, a random winner is selected, who can then withdraw the accumulated prize pool.

The goal of this project is to demonstrate how blockchain technology can ensure **fairness**, **transparency**, and **verifiable randomness** in lottery systems.

---

## ⚙️ Features

- Fully decentralized — no central authority controls the lottery.
- All entries and transactions are recorded on-chain.
- Winner selection logic implemented in Solidity.
- Easy to integrate with a frontend using `ethers.js` or `web3.js`.
- Designed for future integration with **Chainlink VRF** for provable randomness.

---

## 🧩 Contract Workflow

1. A player calls `enterLottery()` and sends the required entry fee.
2. The player’s address is added to the participants list.
3. Once conditions are met (time, participant count, etc.), the contract owner calls `pickWinner()`.
4. A pseudo-random winner is selected.
5. The winner can call `withdrawPrize()` to claim their winnings.
6. The lottery resets and a new round can begin.

> ⚠️ The current version uses a simple pseudo-random method for testing.  
> It is **not suitable for production use** — integrate Chainlink VRF for real randomness.



