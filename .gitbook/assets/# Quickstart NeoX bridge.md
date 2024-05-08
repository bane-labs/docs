# Bridging Assets between Neo N3 and Neo X

This guide helps users quickly move GAS or any NEP-11 tokens from Neo N3 to NeoX, or vice versa, using the [Neo X bridge](https://t3bridge.banelabs.org/).

We will walk you through the entire process, explaining each step in depth. If you get stuck at any point, feel free to reach out to us on [Discord](https://discord.gg/neosmarteconomy) for assistance.

## Prerequisites

To get started quickly, you need to have:

- A web3 wallet installed, such as [Neoline](https://neoline.io/en/) or [Metamask](https://metamask.io/download/). If you don't have one, visit the link to download.
- Some GAS on Neo N3. There are several ways to acquire *GAS* :
  - Use a supported centralized exchange like Binance or OKX, which allows you to buy *GAS* and withdraw it to your wallet. Most major centralized exchanges support direct withdrawal from your centralized exchange wallet to Neo N3
  - Request funds from a faucet for [Testnet N3T5](https://n3t5wish.ngd.network/#/), if you are using a testnet

### Depositing GAS (from Neo N3 to Neo X)

#### Step 1: Add the Neo X network to your Metamask


You'll also need to add the Neo X's RPC endpoint to your wallet. Here we provide two ways for doing this using MetaMask.

* (Recommended) Click the button on the bottom-left of [Neo X's Explorer](https://xt3scan.ngd.network/) to automatically add Neo X to MetaMask

![](https://files.gitbook.com/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F9XHO2y3ZR9IUy80jltkz%2Fuploads%2FkvN6tK728Vbfoesw8s2J%2FScreenshot%202024-04-23%20at%2014.32.08.png?alt=media&token=8f2817eb-9367-44b4-b6cb-e156dab11961)


* On your browser, click on the MetaMask extension. 

  1. Click the network selector drop-down on the top-left corner, and then click `Add Network`. 
  2. Click `Add a network manually` and then provide the information corresponding to the chain you want to send your assets to.


![](https://files.gitbook.com/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F9XHO2y3ZR9IUy80jltkz%2Fuploads%2FrSqLvmByl2ycGGRQYt0Q%2FScreenshot%202024-04-23%20at%2014.22.26.png?alt=media&token=343e26c8-61b4-4800-91db-aaf83bac826d)


The information about NeoX is listed as below:

| [ Parameter]               | [ Neo X Mainnet] | [ Neo X Testnet]                                                       |
| -------------------- | ------- | ------------------------------------------------------------- |
| Network name       | Neo X | Neo X Testnet                                               |
| RPC URL            |       | [https://neoxseed1.ngd.network](https://neoxseed1.ngd.network) |
| Chain ID           |       | 12227331                                                    |
| Currency symbol    | GAS   | GAS                                                         |
| Block explorer URL |       | [https://xt3scan.ngd.network](https://xt3scan.ngd.network/)    |

#### Step 2: Initiate the deposit

1. Go to [https://t3bridge.banelabs.org](https://t3bridge.banelabs.org/).  

2. Log in to the bridge with your wallet. Check that you're connected to Neo N3 and NeoX on the page for asset deposits..

   ![](https://files.gitbook.com/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F9XHO2y3ZR9IUy80jltkz%2Fuploads%2Fbh1yUyuizEz8kIHKvsD7%2FScreenshot%202024-04-23%20at%2010.48.04%20copy.png?alt=media&token=b3b0db89-45f6-4104-8f33-380ee443cff1)

   > Note: Neo X TestNet currently only supports the bridging of  *GAS* .

3. Enter the amount of *GAS*  you want to bridge over in the **From** box and then press `Deposit`. Follow the prompts on your Neo N3 wallet. You can also click `MAX` to deposit all *GAS* to NeoX.

   ![](https://files.gitbook.com/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F9XHO2y3ZR9IUy80jltkz%2Fuploads%2F3pcj7LjL9QcEjQ3YmGKP%2FScreenshot%202024-04-23%20at%2010.48.04%20copy%202.png?alt=media&token=f2b77d49-fc3c-48bb-bbe1-aabb469d3267)

   > **ENSURE SUFFICIENT GAS BALANCE**
   > Please make sure you leave enough GAS on your wallet to pay for the transaction, otherwise there will be no web3 wallet popup. When you click \MAX, GAS for transaction fee will be remained.

It usually takes around 1-2 minutes (varying based on the chain congestion) for funds to transfer to NeoX after submitting the transaction from your Neo N3 wallet.

### Withdrawing *GAS* (from Neo X to Neo N3)

1. Log in to [https://t3bridge.banelabs.org](https://t3bridge.banelabs.org) with your wallet. Check that you are connected to the source network (e.g., NeoX) and the destination network (e.g., Neo N3) shown at the top of the page.

   ![](https://files.gitbook.com/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F9XHO2y3ZR9IUy80jltkz%2Fuploads%2FWVM50OORZnEUFK27Mk2H%2FScreenshot%202024-04-23%20at%2011.19.35%20copy.png?alt=media&token=1f67e6d5-06bc-4da8-b6e0-a5c2b33ba977)

2. Enter the amount of *GAS* you want to bridge over in the `From` box and then press `Withdraw`. Follow the prompts on your web3 wallet.

   ![](https://files.gitbook.com/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F9XHO2y3ZR9IUy80jltkz%2Fuploads%2FiibWSkPmvzat09uXM6PI%2FScreenshot%202024-04-23%20at%2011.19.35%20copy%202.png?alt=media&token=ed0b229a-8aaf-48b0-a5c4-1bdcf43a3f82)

   > **ENSURE SUFFICIENT GAS BALANCE**
   > It is important to have enough GAS in your wallet to complete the transaction, or else the web3 wallet will not pop-up.

It usually takes around 1-2 minutes (varying based on the chain congestion) for funds to transfer to Neo N3 after submitting the transaction from your Metamask.

