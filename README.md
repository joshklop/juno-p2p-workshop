# Juno P2P Workshop

This workshop is based on the tutorial in the [announcement blog post](https://medium.com/nethermind-eth/junos-experimental-peer-to-peer-launch-3040e195550d).

`run.sh`: sync three Juno nodes using p2p on the Sepolia testnet. The first node is the "feeder node" that syncs directly from the centralized sequencer, the second node syncs from the feeder node over p2p, and the third syncs from the second over p2p.

![](./topology.png)

`reset.sh`: stop, tear down the nodes, and clean up.
