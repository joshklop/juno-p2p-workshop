#!/usr/bin/env sh

set -e

bold() {
    echo -e "\033[1m$1\033[0m"
}

gen_env_vars() {
    prefix=$1
    while IFS= read -r line; do
        value=$(echo $line | awk '{ print $NF }' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' )
        key=$(echo $line | cut -f1 -d':' | sed 's/[[:space:]]*$//' | tr ' ' '_' | tr '[:lower:]' '[:upper:]')
        export "${prefix}_${key}"="$value"
    done
}

bold 'Creating Docker Network "juno"'
docker network create juno

bold 'Generating key pair and ID for feeder node'
docker run --rm -it nethermind/juno:v0.10.0 genp2pkeypair > /tmp/juno_file
gen_env_vars FEEDER < /tmp/juno_file

echo $FEEDER_P2P_PRIVATE_KEY
echo $FEEDER_P2P_PEERID

bold 'Starting feeder node (syncing from centralized Sepolia sequencer)'
docker run -d --name juno_feeder \
    --network juno \
    -p 6060:6060 \
    -p 7777:7777 \
    -v ./juno_sepolia_feeder:/var/lib/juno_feeder \
    nethermind/juno:v0.10.0 \
    --db-path "/var/lib/juno_feeder" \
    --network "sepolia" \
    --log-level "debug" \
    --http \
    --http-host "0.0.0.0" \
    --http-port "6060" \
    --p2p \
    --p2p-feeder-node \
    --p2p-private-key=$FEEDER_P2P_PRIVATE_KEY \
    --p2p-addr="/ip4/0.0.0.0/tcp/7777"

bold 'Generating key pair and ID for first peer'
docker run --rm -it nethermind/juno:v0.10.0 genp2pkeypair > /tmp/juno_file
gen_env_vars PEER1 < /tmp/juno_file

bold 'Starting first peer (syncing from feeder node)'
docker run -d --name juno_peer1 \
    --network juno \
    -p 6061:6061 \
    -p 7778:7778 \
    -v ./juno_sepolia_peer1:/var/lib/juno_peer1 \
    nethermind/juno:v0.10.0 \
    --db-path "/var/lib/juno_peer1" \
    --network "sepolia" \
    --log-level "debug" \
    --http \
    --http-host "0.0.0.0" \
    --http-port "6061" \
    --p2p \
    --p2p-addr=/ip4/0.0.0.0/tcp/7778 \
    --p2p-peers=/dns4/juno_feeder/tcp/7777/p2p/$FEEDER_P2P_PEERID \
    --p2p-private-key=$PEER1_P2P_PRIVATE_KEY

bold 'Starting second peer using auto-generated key and ID (syncing from peer 1)'
docker run -d --name juno_peer2 \
    --network juno \
    -p 6062:6062 \
    -p 7779:7779 \
    -v ./juno_sepolia_peer2:/var/lib/juno_peer2 \
    nethermind/juno:v0.10.0 \
    --db-path "/var/lib/juno_peer2" \
    --network "sepolia" \
    --log-level "debug" \
    --http \
    --http-host "0.0.0.0" \
    --http-port "6062" \
    --p2p \
    --p2p-addr=/ip4/0.0.0.0/tcp/7779 \
    --p2p-peers=/dns4/juno_peer1/tcp/7779/p2p/$PEER1_P2P_PEERID
