#!/usr/bin/env sh

docker rm -f juno_feeder
docker rm -f juno_peer1
docker rm -f juno_peer2
docker network rm juno

sudo rm -rf ./juno_sepolia_feeder
sudo rm -rf ./juno_sepolia_peer1
sudo rm -rf ./juno_sepolia_peer2
