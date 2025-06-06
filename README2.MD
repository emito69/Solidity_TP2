Solidity_TP2

<div id="header" align="center">
  <h2 align="center"> <img src="https://github.com/devicons/devicon/blob/master/icons/solidity/solidity-plain.svg" title="Solidity" alt="Solidity" height="30" width="40"/> Auction SmartContract - TP2 Solidity <img src="https://github.com/devicons/devicon/blob/master/icons/solidity/solidity-plain.svg" title="Solidity" alt="Solidity" height="30" width="40"/> </h2>
  <h6 align="center"> I´m an Electronics Engineer working as an Instrumentation and Control Engineer at Transportadora de Gas del Sur (TGS) in Argentina.</h6>
  <h6 align="center"> I have also completed courses of Machine Learnign, Artificial Intelligence and Web develepment.</h6>
  <br>
</div>

<div align="left">
<small>This is some smaller text.</small>
</div>

<hr>
<hr>

Welcome to Chainlink developer documentation repository. This repository is the source for developer documentation on [docs.chain.link](https://docs.chain.link/), which is a resource for smart contract developers and node operators building decentralized applications on several networks.

This documentation is open source. If you want to contribute tutorials or improvements, see the [Contributing](https://github.com/smartcontractkit/documentation/blob/main/CONTRIBUTING.md) guide.

> [!NOTE]
> The code samples in this documentation are examples for using Chainlink products and services and are provided to help you understand how to
> interact with Chainlink's systems and services so that you can integrate them into your own. These templates are provided
> "AS IS" and "AS AVAILABLE" without warranties of any kind, have not been audited, and may be missing key checks or
> error handling to make the usage of the product more clear. Do not use the example code in a production
> environment without completing your own audits and application of best practices. Neither Chainlink Labs, the
> Chainlink Foundation, nor Chainlink node operators are responsible for unintended outputs that are generated due to
> errors in code.

## Developing

To run a local development environment, use the following command:

```
npm install && npm run dev
```

## Docs architecture

- All docs are markdown and stored in `/src/content`.
- Navigation is JSON in `/src/config/sidebar.ts`

## Deploy Preview

This repo is configured to automatically create a preview environment on Vercel when a PR is opened. After the deployment is approved, the Vercel bot will leave a comment with a link to the preview on your PR.

## Deploying to Production

This repo is configured to automatically update the production (`https://docs.chain.link`) site when commits are pushed to the `main` branch.

## Referencing Chainlink documentation

If you want to reference Chainlink documentation in your documentation, please include direct links to the page(s) you're referencing, so that your users can easily access the latest information. We also recommend keeping the amount of content that you quote to a minimum, in order to reduce the maintenance burden on your side.

For example:

```solidity
Ethereum is integrated with the following Chainlink services:
- [Data Feeds](https://docs.chain.link/data-feeds/price-feeds/addresses?network=ethereum)
- [CCIP](https://docs.chain.link/ccip/directory/mainnet/chain/mainnet)
- [Functions](https://docs.chain.link/chainlink-functions/supported-networks#ethereum)
- [Automation](https://docs.chain.link/chainlink-automation/overview/supported-networks#ethereum)
- [VRF](https://docs.chain.link/vrf/v2-5/supported-networks#ethereum-mainnet)

Additionally, you may need to refer to the [LINK Token Contracts for Ethereum](https://docs.chain.link/resources/link-token-contracts#ethereum).
```

The most relevant documentation links for each supported chain and for each product are available in [this table](https://docs.chain.link/builders-quick-links).

