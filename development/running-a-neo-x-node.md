# Running a Neo X Node

This document contains step-by-step instructions for running a geth node in Neo X.

## 1. Hardware Requirements

The following are the minimum hardware requirements:

#### Seed Node

* CPU with 2+ cores
* 4 GB RAM
* 200GB free storage space for data synchronization
* 8 MBit/sec download Internet service

#### Miner Node

* Fast CPU with 2+ cores
* 16 GB RAM
* 200 GB free storage space for data synchronization
* 8 MBit/sec download Internet service

## 2. Building or Downloading Geth Binary

#### Build from source

Building `geth` requires both a Go (version 1.23 or later) and a C compiler. Feel free to install them with the package manager of your choice.

Once the dependencies are installed, run

```
make geth
```

or, build the full suite of utilities:

```
make all
```

#### Download the binary

You can download the latest `geth` binary from [https://github.com/bane-labs/go-ethereum/releases](https://github.com/bane-labs/go-ethereum/releases)

## 3. Initializing Geth Database

Download the latest release version of both binary and configuration file from:&#x20;

[https://github.com/bane-labs/go-ethereum/releases/tag/v0.4.2](https://github.com/bane-labs/go-ethereum/releases/tag/v0.4.2)

[https://github.com/bane-labs/go-ethereum/blob/v0.4.2/config](https://github.com/bane-labs/go-ethereum/blob/v0.4.2/config)

To create a blockchain node that uses this genesis block, first use `geth init` to import and set the canonical genesis block for the new chain. This requires the path to the configuration file to be passed as an argument.

&#x20;`--datadir` is the target destination for the node database. Here we use `./node`:

Testnet

```
./geth init --datadir ./node ./genesis_testnet.json
```

Mainnet

```
./geth init --datadir ./node ./genesis_mainnet.json
```

## 4.a. Start a Seed Node

A seed node is a network member that does not participate in the consensus process. This node can be used to interact with the Neo X network, including: creating accounts, transferring funds, deploying and interacting with contracts, and querying node APIs.

### 4.a.1. Start with Script

Create the `startSeed.sh` file in the same folder of `geth`. You may need to change the `P2P/HTTP/RPC/WS` ports to avoid conflicts. Please note that the port configuration for the JSON-RPC interface should be set to httpport, not rpcport. Additionally, remember to change `extip` to your own IP address if you want other nodes to be able to find yours. You can refer to [https://geth.ethereum.org/docs/fundamentals/command-line-options](https://geth.ethereum.org/docs/fundamentals/command-line-options) for more details about start options.

This script expects node DB directory to be `./node`.

#### Testnet:

```
#!/bin/bash
​
node="./node"
​
port=30301
httpport=8551
rpcport=8561
wsport=8571
extip=127.0.0.1
​
nohup ./geth \
--networkid 12227332 \
--nat extip:$extip \
--port $port \
--authrpc.port $rpcport \
--identity=$node \
--maxpeers=50 \
--syncmode full \
--gcmode archive \
--datadir $node \
--bootnodes "enode://65775722283d6b19cf64c875897faf34ee120dc686c552d11c1310ee3d44bad0da88cfd9cef53a92c10604f8140d5210c4381e3e7a99322400130b5b8d4d331b@34.143.193.38:30301" \
--http.api admin,eth,debug,miner,net,txpool,personal,web3,dbft \
--http --http.addr 0.0.0.0 --http.port $httpport --http.vhosts "*" --http.corsdomain '*' \
--ws --ws.addr 0.0.0.0 --ws.port $wsport --ws.api eth,net,web3 --ws.origins '*'  \
--verbosity 3  >> $node/node.log 2>&1 &
​
sleep 3s;
ps -ef|grep geth|grep mine|grep -v grep;
```

#### Mainnet:

```
#!/bin/bash
​
node="./node"
​
port=30301
httpport=8551
rpcport=8561
wsport=8571
extip=127.0.0.1
​
nohup ./geth \
--networkid 47763 \
--nat extip:$extip \
--port $port \
--authrpc.port $rpcport \
--identity=$node \
--maxpeers=50 \
--syncmode full \
--gcmode archive \
--datadir $node \
--bootnodes "enode://ca6dabad08eda7cdae931df4ee2386a723676538932c5179887b6c6741246cebe60da42d14cad88fd8bb29eda7ccade48f889a422001f85cba0a794c955c8fd5@35.238.46.225:30301" \
--http.api admin,eth,debug,miner,net,txpool,personal,web3,dbft \
--http --http.addr 0.0.0.0 --http.port $httpport --http.vhosts "*" --http.corsdomain '*' \
--ws --ws.addr 0.0.0.0 --ws.port $wsport --ws.api eth,net,web3 --ws.origins '*'  \
--verbosity 3  >> $node/node.log 2>&1 &
​
sleep 3s;
ps -ef|grep geth|grep mine|grep -v grep;
```

Then run

```
./startSeed.sh
```

## 4.b. Start a Miner Node

A miner node participates in the consensus process. If you want to register as a candidate for the consensus list, you need to run a miner node.

### 4.b.1. Initialize Node Account

You can create a new account or import an existing account for your node operation. Seed nodes don't need node account.

#### Create a new account

Create your node account with the following command. A password is required to be entered during the process. The resulting account is placed in the specified `--datadir` under the `keystore` path.

```
./geth --datadir ./node account new
```

#### Import your existing account

Import your existing account with the private key and remember to replace the `./your/privateKey.txt` parameter.

```
./geth account import --datadir ./node ./your/privateKey.txt
```

When the inputing node index is set to 1, this script requires the node address to be placed at `node/node_address.txt`, the node password to be placed at `node/password.txt` and the node DB directory to be placed at `./node`.

### 4.b.2. Create an Anti-MEV Keystore

Validators and candidates participating in dBFT consensus must set up an Anti-MEV keystore, or the node will fail to enable the miner functionality.

To create an Anti-MEV keystore for your validator account, run:

```
./geth --datadir ./node antimev init <address>
```

You will be prompted to enter a password for the keystore.

### 4.b.3. Download ZK Files

Validators participating in onchain DKG must have three pairs of R1CS files and proving keys for Groth16 proof generation.

You can download these files from [Neo X MPC](https://github.com/bane-labs/mpc) through [NeoFS](https://fs.neo.org/) or cloud URLs.

### 4.b.4. Start with Script

Create the `startMiner.sh` file in the same folder of `geth`. You may need to change the `P2P/RPC` ports to avoid conflicts. Additionally, remember to change `extip` if you want other nodes to be able to find yours. You can refer to [https://geth.ethereum.org/docs/fundamentals/command-line-options](https://geth.ethereum.org/docs/fundamentals/command-line-options) for more details about start options.

#### Testnet:

```
#!/bin/bash

node="./node"

port=30301
httpport=8551
rpcport=8561
wsport=8571
extip=127.0.0.1

miner=$(<$node/node_address.txt)

nohup ./geth \
--networkid 12227332 \
--nat extip:$extip \
--port $port \
--mine --miner.etherbase=$miner \
--unlock $miner \
--password $node/password.txt \
--antimev.password $node/password.txt \
--dkg.one-msg-r1cs=./r1cs/one_message.ccs \
--dkg.two-msg-r1cs=./r1cs/two_message.ccs \
--dkg.seven-msg-r1cs=./r1cs/seven_message.ccs \
--dkg.one-msg-pk=./pk/one_message.pk \
--dkg.two-msg-pk=./pk/two_message.pk \
--dkg.seven-msg-pk=./pk/seven_message.pk \
--authrpc.port $rpcport \
--identity=$node \
--maxpeers=50 \
--syncmode full \
--gcmode archive \
--datadir $node \
--bootnodes "enode://65775722283d6b19cf64c875897faf34ee120dc686c552d11c1310ee3d44bad0da88cfd9cef53a92c10604f8140d5210c4381e3e7a99322400130b5b8d4d331b@34.143.193.38:30301" \
--verbosity 3  >> $node/node.log 2>&1 &

sleep 3s;
ps -ef|grep geth|grep mine|grep -v grep;
```

#### Mainnet:

```
#!/bin/bash
​
node="./node"

port=30301
httpport=8551
rpcport=8561
wsport=8571
extip=127.0.0.1
​
miner=$(<$node/node_address.txt)
​
nohup ./geth \
--networkid 47763 \
--nat extip:$extip \
--port $port \
--mine --miner.etherbase=$miner \
--unlock $miner \
--password $node/password.txt \
--antimev.password $node/password.txt \
--dkg.one-msg-r1cs=./r1cs/one_message.ccs \
--dkg.two-msg-r1cs=./r1cs/two_message.ccs \
--dkg.seven-msg-r1cs=./r1cs/seven_message.ccs \
--dkg.one-msg-pk=./pk/one_message.pk \
--dkg.two-msg-pk=./pk/two_message.pk \
--dkg.seven-msg-pk=./pk/seven_message.pk \
--authrpc.port $rpcport \
--identity=$node \
--maxpeers=50 \
--syncmode full \
--gcmode archive \
--datadir $node \
--bootnodes "enode://ca6dabad08eda7cdae931df4ee2386a723676538932c5179887b6c6741246cebe60da42d14cad88fd8bb29eda7ccade48f889a422001f85cba0a794c955c8fd5@35.238.46.225:30301" \
--verbosity 3  >> $node/node.log 2>&1 &
​
sleep 3s;
ps -ef|grep geth|grep mine|grep -v grep;
```

Then run

```
./startMiner.sh
```

### 4.b.5. Registering as a Candidate

After running a miner node, you can stake 1000 GAS to register as a candidate for the consensus list. If your node receives enough votes (top 7 in GAS), it will become a consensus node, which will mint blocks and share the transaction fee rewards.

#### Attach the node IPC

```
./geth attach ./node/geth.ipc
```

#### Call the Governance contract

```
var abi = [{
  "inputs": [
    {
      "internalType": "uint256",
      "name": "shareRate",
      "type": "uint256"
    },
    {
      "internalType": "bytes",
      "name": "pubkey",
      "type": "bytes"
    }
  ],
  "name": "registerCandidate",
  "outputs": [],
  "stateMutability": "payable",
  "payable": "true",
  "type": "function"
}];

var govContract = web3.eth.contract(abi);
var govInstance = GovContract.at('0x1212000000000000000000000000000000000001');

// send 1000 GAS (This value is 20000 in current testnet) and call registerCandidate(shareRate)
// shareRate is the rate share to voters, the rate base is 1000, 100 means 10%
govInstance.registerCandidate(100, ANTIMEV_KEYSTORE_PUBKEY, {value:'1000000000000000000000', from: eth.accounts[0]});
```
