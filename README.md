
<!--
**emito69/emito69** is a ✨ _special_ ✨ repository because its `README.md` (this file) appears on your GitHub profile.
Here are some ideas to get you started:
- 🔭 I’m currently working on ...
- 🌱 I’m currently learning ...
- 👯 I’m looking to collaborate on ...
- 🤔 I’m looking for help with ...
- 💬 Ask me about ...
- 📫 How to reach me: ...
- 😄 Pronouns: ...
- ⚡ Fun fact: ...

En el README de github no puedo añadir scrpits de java o css, tengo que trabajar directamente con atributos en html
-->

Solidity_TP2

<div id="header" align="center">
  <h2 align="center"> <img src="https://github.com/devicons/devicon/blob/master/icons/solidity/solidity-plain.svg" title="Solidity" alt="Solidity" height="30" width="40"/> Auction SmartContract - TP2 Solidity <img src="https://github.com/devicons/devicon/blob/master/icons/solidity/solidity-plain.svg" title="Solidity" alt="Solidity" height="30" width="40"/> </h2>
  Code Documentation and Explanation
  <h6 align="center"> This repository contains a Solidity smart contract implementing a time-limited auction system with automatic extension functionality. The contract manages bids, tracks participants, handles fund distribution, and provides transparent auction information.</h6>
  <br>
</div>

## Table of Contents
1. [Contract Overview](#contract-overview)
2. [Key Features](#key-features)
3. [Technical Specifications](#technical-specifications)
4. [Contract Structure](#contract-structure)
5. [Usage Guide](#usage-guide)
6. [Events](#events)
7. [Security Considerations](#security-considerations)
8. [License](#license)

## Contract Overview


```
The Tp2_Auction contract implements an English auction mechanism where:

- Bidders submit increasingly higher bids

- The auction has a minimum starting bid (1000000 wei)

- Each new bid must be at least 5% higher than the current highest bid

- The auction automatically extends if bids are placed near the expiration time

- Funds are securely managed and distributed after auction conclusion
```

## Key Features

### Core Functionality
```
- Time-limited auction with 1-week initial duration

- 10-minute extension window when bids are placed near expiration

- Minimum 5% bid increment requirement

- Transparent bid history tracking

- Secure fund management
```
### Participant Management
```
- Automatic tracking of unique bidders

- Balance management for each participant

- Clear winner determination

- Secure claim process for non-winning bidders
```
## Technical Specifications

### Environment Requirements
```
- Solidity ^0.8.0

- Hardhat (for development and testing)

- Compatible with EVM blockchains
```
### Contract Variables
```
| Variable | Type | Description |
|----------|------|-------------|
| `owner` | `address` | Contract administrator |
| `init_value` | `uint256` | Initial minimum bid value |
| `expiration` | `uint256` | Auction end timestamp |
| `state` | `enum State` | Current auction state (on/off) |
| `winner` | `struct Person2` | Current highest bidder |
```
## Contract Structure

### Data Structures

```solidity
struct Person {
    address id;       // Bidder address
    uint256 value;    // Last valid bid amount
    uint256 balance;  // Total deposited funds
}

struct Person2 {
    address id;       // Participant address
    uint256 value;    // Transaction amount
}
```
### Modifiers
```
modifier onlyOwner()       // Restricts to contract owner
modifier isBidderM()       // Verifies registered bidder
modifier auctionAlive()    // Ensures auction is active
modifier auctionEnded()    // Ensures auction has concluded
modifier validOffer()      // Validates bid requirements
```

## Usage Guide
### Placing a Bid

```javascript
// To place a bid:
auctionContract.Offer({value: bidAmount});
// Minimum bid: current highest bid * 1.05
```
### Checking Auction Status

```javascript
// View current winner:
const winner = await auctionContract.showWinner();

// View all bids:
const bids = await auctionContract.showOffers();
```
### Claiming Funds

```javascript
// For bidders to claim excess funds:
await auctionContract.claim();

// For owner to distribute funds after auction:
await auctionContract.returnOffers();

// For owner to withdraw proceeds:
await auctionContract.ownerClaim();
```

## Events
### NewOffer

```
Emitted when a valid bid is placed
- Parameters:
  - address indexed _id: Bidder address
  - uint256 _value: Bid amount
```
### AuctionEnded

```
Emitted when auction concludes
- Parameters:
  - address _id: Winner address
  - uint256 _value: Winning amount
```

## Security Considerations

```
1. All fund transfers use 2300 gas limit to prevent reentrancy
2. Critical functions are owner-restricted
3. Bid validation includes both amount and timing checks
4. State transitions are carefully controlled
5. Funds are automatically returned after auction conclusion
```

## License

```
MIT License
Copyright (c) [year] [fullname]
```

<hr>
<h6 align="center"> This README provides comprehensive documentation for developers and users of the auction contract. The clear structure and detailed explanations make it easy to understand and implement the auction system.</h6>
<h6 align="center"> "El blockchain no es solo tecnología, es una revolución en la forma como intercambiamos valor y confianza." - Anónimo.</h6>




<hr>
<div align="center">
 <h4> 🛠 Lenguages & Tools : </h4>
  <img src="https://github.com/devicons/devicon/blob/master/icons/solidity/solidity-plain.svg" title="Solidity" alt="Solidity" height="30" width="40"/>
  <img src="https://github.com/devicons/devicon/blob/master/icons/solidity/solidity-original.svg" title="Solidity" alt="Solidity" height="30" width="40"/>
  <img src="https://github.com/devicons/devicon/blob/master/icons/solidity/solidity-plain.svg" title="Solidity" alt="Solidity" height="30" width="40"/>
  <br>
</div>

<hr>
 <h4> 🔭 About me : </h4>

- 📝  I am an Instrumentation and Control engineer who constantly trains to keep up with new technologies.

- 📫 How to reach me: [my Linkedin](https://www.linkedin.com/in/emiliano-alvarez-a6677b1b4).

<br>
<div id="badges" align="center">
    <a href="https://www.linkedin.com/in/emiliano-alvarez-a6677b1b4/">
        <img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white" alt="Linkedin Badge"  style="max-width: 100%;">
    </a> 
</div>
<br>
</div>
