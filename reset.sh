#!/usr/bin/env sh

docker rm -vf juno_feeder juno_peer1 juno_peer2
docker network rm juno
sudo rm -rf ./juno_sepolia_feeder ./juno_sepolia_peer1 ./juno_sepolia_peer2
