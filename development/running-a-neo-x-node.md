# Running a Neo X Node

This document contains step-by-step instructions for running a geth node in Neo X.

## Hardware Requirements

The following are the minimum hardware requirements:

* CPU with 2+ cores
* 4GB RAM
* 200GB free storage space to sync the Testnet
* 8 MBit/sec download Internet service

## 1. Building or Downloading Geth Binary

### Build the source

Building `geth` requires both a Go (version 1.19 or later) and a C compiler. Feel free to install them with the package manager of your choice.

Once the dependencies are installed, run

```
make geth
```

or, build the full suite of utilities:

```
make all
```

### Download the geth binary for linux

You can download the latest `geth-linux-amd64` binary from [https://github.com/bane-labs/go-ethereum/releases](https://github.com/bane-labs/go-ethereum/releases)

## 2. Initializing Geth Database

Download the latest .json configuration file from [https://github.com/bane-labs/go-ethereum/tree/bane-main/config](https://github.com/bane-labs/go-ethereum/tree/bane-main/config).

To create a blockchain node that uses this genesis block, first use geth init to import and set the canonical genesis block for the new chain. This requires the path to the configuration file to be passed as an argument.

&#x20;`--datadir` is the target destination for the node database. Here we use `./nodes/node1`:

Testnet

```
./geth init --datadir ./nodes/node1 ./genesis_testnet.json
```

Mainnet

```
./geth init --datadir ./nodes/node1 ./genesis_mainnet.json
```

## 3. Initializing Node Account

You can create a new account or import an existing account for your node operation. Seed nodes don't need node account.

### Create a new account

Create your node account with the following command. A password is required to be entered during the process. The resulting account is placed in the specified `--datadir` under the `keystore` path.

```
./geth --datadir ./nodes/node1 account new
```

### Import your existing account

Import your existing account with the private key and remember to replace the `./your/privateKey.txt` parameter.

```
./geth account import --datadir ./nodes/node1 ./your/privateKey.txt
```

## 4. Running Seed Node

A seed node is a network member that does not participate in the consensus process. This node can be used to interact with the Neo X network, including: creating accounts, transferring funds, deploying and interacting with contracts, and querying node APIs.

Create the `startSeed.sh` file in the same folder of `geth`. You may need to change the `P2P/HTTP/RPC/WS` ports to avoid conflicts. Please note that the port configuration for the JSON-RPC interface should be set to httpport, not rpcport. Additionally, remember to change `extip` to your own IP address if you want other nodes to be able to find yours. You can refer to [https://geth.ethereum.org/docs/fundamentals/command-line-options](https://geth.ethereum.org/docs/fundamentals/command-line-options) for more details about start options.

This script expects node DB directory to be `./node/node1`.

#### Testnet:

```
#!/bin/bash
​
node="nodes/node1"
​
port=30301
httpport=8551
rpcport=8561
wsport=8571
extip=127.0.0.1
​
echo "$node and miner is $miner, rpc port $rpcport, p2p port $port"
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
node="nodes/node1"
​
port=30301
httpport=8551
rpcport=8561
wsport=8571
extip=127.0.0.1
​
echo "$node and miner is $miner, rpc port $rpcport, p2p port $port"
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
./startMember.sh
```

## 5. Running Miner Node

A miner node participates in the consensus process. If you want to register as a candidate for the  consensus list, you need to run a miner node.

Create the startMiner.sh file in the same folder of `geth`. You may need to change the `P2P/RPC` ports to avoid conflicts. Additionally, remember to change `extip` if you want other nodes to be able to find yours. You can refer to [https://geth.ethereum.org/docs/fundamentals/command-line-options](https://geth.ethereum.org/docs/fundamentals/command-line-options) for more details about start options.

When the inputing node index is set to 1, this script requires the node address to be placed at `nodes/node1/node_address.txt`, the node password to be placed at `nodes/node1/password.txt` and the node DB directory to be placed at `./node/node1`.

#### Testnet:

```
#!/bin/bash

echo "input node index"
read nodeIndex
node="nodes/node$nodeIndex"

startP2PPort=30300
startRPCPort=8561

port=`expr $startP2PPort + $nodeIndex`
rpcport=`expr $startRPCPort + $nodeIndex`
extip=127.0.0.1

miner=$(<$node/node_address.txt)
echo "$node and miner is $miner, rpc port $rpcport, p2p port $port"

nohup ./geth \
--networkid 12227332 \
--nat extip:$extip \
--port $port \
--mine --miner.etherbase=$miner \
--unlock $miner \
--password $node/password.txt \
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
echo "input node index"
read nodeIndex
node="nodes/node$nodeIndex"
​
startP2PPort=30300
startRPCPort=8561
​
port=`expr $startP2PPort + $nodeIndex`
rpcport=`expr $startRPCPort + $nodeIndex`
extip=127.0.0.1
​
miner=$(<$node/node_address.txt)
echo "$node and miner is $miner, rpc port $rpcport, p2p port $port"
​
nohup ./geth \
--networkid 47763 \
--nat extip:$extip \
--port $port \
--mine --miner.etherbase=$miner \
--unlock $miner \
--password $node/password.txt \
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

## 6. Registering as a Candidate

After running a miner node, you can stake 2000 GAS to register as a candidate for the consensus list. If your node receives enough votes (top 7 in GAS), it will become a consensus node, which will mint blocks and share the transaction fee rewards.

1. Attach the node

```
./geth attach nodes/node1/geth.ipc
```

2. Call the Governance contract

```
var abi=[ {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "shareRate",
          "type": "uint256"
        }
      ],
      "name": "registerCandidate",
      "outputs": [],
      "stateMutability": "payable",
      "payable": "true",
      "type": "function"
    } ];

var GovContract = web3.eth.contract(abi);

var govInstance = GovContract.at('0x1212000000000000000000000000000000000001');

// send 2000 GAS(This value is 20000 in current testnet) and call registerCandidate(shareRate), shareRate is the rate share to voters, the rate base is 1000, 100 means 10%
govInstance.registerCandidate(100, {value:'2000000000000000000000', from: eth.accounts[0]});
```
