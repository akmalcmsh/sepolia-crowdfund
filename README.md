# Crowdfunding DApp

This project is a simple, best-practice Ethereum crowdfunding DApp.

## Structure
- `contracts/CrowdFund.sol` — Solidity smart contract
- `index.html` — Frontend (HTML/JS, uses ethers.js)

## How to Use

### 1. Deploy the Contract
- Open [Remix IDE](https://remix.ethereum.org)
- Compile `CrowdFund.sol` (Solidity 0.8.17+)
- Deploy with:
  - `_goal`: e.g. `1000000000000000000` (1 ETH, in wei)
  - `_durationInDays`: e.g. `30`
- Copy the deployed contract address

### 2. Configure the Frontend
- Open `index.html` in a code editor
- Set `let contractAddress = 'YOUR_CONTRACT_ADDRESS';`
- Paste the contract ABI (from Remix Compilation Details) into `contractABI`
- Save the file

### 3. Run the Frontend
- Open `index.html` in your browser
- Connect MetaMask (ensure you’re on the same network as deployment)
- Use the UI to contribute, withdraw (owner), or request a refund

## Features
- Anyone can contribute ETH (min 0.01 ETH)
- Owner can withdraw if goal is reached
- Contributors can refund if goal not reached by deadline
- Campaign details and balances update live

## Best Practices
- Access control with `modifier`
- Events for all major actions
- Input validation with `require()`
- Clean, readable code and UI

---

**Demo Tips:**
- Show contract deployment
- Show frontend interaction (contribute, withdraw, refund)
- Explain your code and workflow simply

If you get stuck, check the browser console for errors or ask for help!
