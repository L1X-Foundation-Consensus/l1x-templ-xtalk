#!/bin/bash

# Configuration environment variables

# VALIDATOR PRIVATE KEY DEV
export VALIDATOR_PRIVATE_KEY_DEV="6d657bbe6f7604fb53bc22e0b5285d3e2ad17f64441b2dc19b648933850f9b46"
export VALIDATOR_PUBLIC_KEY_DEV="0215edb7e9a64f9970c60d94b866b73686980d734874382ad1002700e5d870d945"

# Random keypair for testing
export NODE_PUBLIC_KEY="043f7470e3d91158fbd93fb40f09df58296d550bd2c36c2edf08ae2da399f2ab647abc8c309db0c7870b48eda78ae8028e6da4c752ae8bf522db1cda1e195bfdbe"
export NODE_PRIVATE_KEY="009b6636f431b8834e0534edf39c9d7c7dc8d478aa2cd3267aa0c20c1b95a344c5"

# Hardcoded block producer public key for the very first session
export GENESIS_BLOCK_PRODUCER="043f7470e3d91158fbd93fb40f09df58296d550bd2c36c2edf08ae2da399f2ab647abc8c309db0c7870b48eda78ae8028e6da4c752ae8bf522db1cda1e195bfdbe"

export BOOTNODES="/ip4/192.168.1.120/tcp/5010/p2p/16Uiu2HAmTsE86DFcMsxrXA2873jv67wok5mG9zde2Us26aGWJvXH;"

# TODO: how previous vars are used?
export NODE_PORT="5010"
export NODE_PRIVKEY="6913aeae91daf21a8381b1af75272fe6fae8ec4a21110674815c8f0691e32758"
export L1X_EXPOSED_PORT="8080"
export DEV_MODE="true"

# Fix this to casandra1
export CASSANDRA_HOST="cassandra1"
export CASSANDRA_PORT="9042"
export REPLICATION_ENABLED="true" # make true for production
export GRPC_HOST="http://l1x-node:50052"
export JSON_RPC_HOST="http://l1x-node:50051"

# 200 Million , Considering 18 Decimals
export GENESIS_AMOUNT="200000000000000000000000000"

# Env for Event Handler Services
export L1X_JSON_PORT="50051"
export L1X_PROTO_PORT="50052"
export L1X_ENDPOINT="http://l1x-node"
export CLI_ARCH="docker"
export L1X_CHAIN_CONFIG="/home/l1x/l1x-ws/l1x-conf/event_listener_chain_config.yaml"
export L1X_P2P_WALLET="/home/l1x/l1x-ws/l1x-conf/event_listener_wallets.json"
export USER_PRIVATE_KEY="e7efc71ab1b2055a474a6593159da8a113ad7025dca27a870e9d535501f1687c"
export CHAIN_ID=5

export ETHEREUM_GOERLI=904a9154641d44348e7fab88570219e9
export OPTIMISM_GOERLI=904a9154641d44348e7fab88570219e9
