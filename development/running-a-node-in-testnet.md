# Running a Node in TestNet

This document contains step-by-step instructions for running a geth node in the Neo X test network.

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

Download the latest `genesis_testnet.json` configuration file from [https://github.com/bane-labs/go-ethereum/blob/bane-main/config/genesis\_testnet.json](https://github.com/bane-labs/go-ethereum/blob/bane-main/config/genesis\_testnet.json).

To create a blockchain node that uses this genesis block, first use geth init to import and set the canonical genesis block for the new chain. This requires the path to genesis.json to be passed as an argument. `--datadir` is the target destination for the node database, here we use `./nodes/node1`.

```
./geth init --datadir ./nodes/node1 ./genesis_testnet.json
```

## 3. Initializing Node Account

Create your node account with the following command. A password is required to be entered during the process. The resulting account is placed in the specified `--datadir` under the `keystore` path.

```
./geth --datadir ./nodes/node1 account new
```

Import your existing account with the private key and remember to replace the `./your/privateKey.txt` parameter.

```
./geth account import --datadir ./nodes/node1 ./your/privateKey.txt
```

## 4. Running Member Node

Create the `startMember.sh` file in the same folder of `geth`. You may need to change the P2P/HTTP/RPC ports. This script expects node DB directory to be `./node/node1`. You can refer to [https://geth.ethereum.org/docs/fundamentals/command-line-options](https://geth.ethereum.org/docs/fundamentals/command-line-options) for more details about start options.

```
$ vi startMember.sh
#!/bin/bash
​
node="nodes/node1"
​
startP2PPort=30300
startHttpPort=8545
startRPCPort=8561
​
port=`expr $startP2PPort + 1`
httpport=`expr $startHttpPort + 1`
rpcport=`expr $startRPCPort + 1`
​
miner=$(<$node/node_address.txt)
echo "$node and miner is $miner, rpc port $rpcport, p2p port $port"
​
nohup ./geth \
--networkid 12227331 \
--port $port \
--authrpc.port $rpcport \
--identity=$node \
--maxpeers=50 \
--txpool.nolocals \
--syncmode full \
--gcmode archive \
--datadir $node \
--bootnodes "enr:-KO4QFuNbtvEaHsiOpEe22LyYJ9FBNDfsvzhBcohnpLcOmopXlk9sKE9JJlT9_JjVb3K0KTPvfNjjArb8c8Qe-geeoaGAY7rxy0Wg2V0aMfGhBL8z2aAgmlkgnY0gmlwhCO764eJc2VjcDI1NmsxoQNhL5qj-6ycHfDYoD3oujZuxH20AOLdU1aoT5gGGSLSaoRzbmFwwIN0Y3CCdl2DdWRwgnZd" \
--http.api admin,eth,debug,miner,net,txpool,personal,web3,dbft \
--http --http.addr 0.0.0.0 --http.port $httpport --http.vhosts "*" --http.corsdomain '*' \
--ws --ws.addr 0.0.0.0 --ws.port 8570 --ws.api eth,net,web3 --ws.origins '*'  \
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

Create the startMiner.sh file in the same folder of `geth`. You may need to change the P2P/HTTP/RPC ports. You can refer to [https://geth.ethereum.org/docs/fundamentals/command-line-options](https://geth.ethereum.org/docs/fundamentals/command-line-options) for more details about start options.

When the node index is set to 1, this script requires the node address to be placed at `nodes/node1/node_address.txt`, the node password to be placed at `nodes/node1/password.txt` and the node DB directory to be placed at `./node/node1`.

```
$ vi startMiner.sh
#!/bin/bash
​
echo "input node index"
read nodeIndex
node="nodes/node$nodeIndex"
​
startP2PPort=30300
startHttpPort=8545
startRPCPort=8561
​
port=`expr $startP2PPort + $nodeIndex`
httpport=`expr $startHttpPort + $nodeIndex`
rpcport=`expr $startRPCPort + $nodeIndex`
​
miner=$(<$node/node_address.txt)
echo "$node and miner is $miner, rpc port $rpcport, p2p port $port"
​
nohup ./geth \
--networkid 12227331 \
--nat extip:10.148.0.2 \
--port $port \
--mine --miner.etherbase=$miner \
--unlock $miner \
--password $node/password.txt \
--authrpc.port $rpcport \
--identity=$node \
--maxpeers=30 \
--txpool.nolocals \
--syncmode full \
--gcmode archive \
--datadir $node \
--bootnodes "enr:-KO4QFuNbtvEaHsiOpEe22LyYJ9FBNDfsvzhBcohnpLcOmopXlk9sKE9JJlT9_JjVb3K0KTPvfNjjArb8c8Qe-geeoaGAY7rxy0Wg2V0aMfGhBL8z2aAgmlkgnY0gmlwhCO764eJc2VjcDI1NmsxoQNhL5qj-6ycHfDYoD3oujZuxH20AOLdU1aoT5gGGSLSaoRzbmFwwIN0Y3CCdl2DdWRwgnZd" \
--metrics --metrics.addr 0.0.0.0 --metrics.expensive \
--verbosity 3  >> $node/node.log 2>&1 &
​
sleep 3s;
ps -ef|grep geth|grep mine|grep -v grep;
```

Then run

```
./startMiner.sh
```
