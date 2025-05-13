# L2-Switch

> L2 switch implementation: L2 forwarding based solely on the MAC address of NDN packets.

---

This repository is part of the [**Pegasus**](https://github.com/NDN-PEGASUS) project, a cross-platform forwarding acceleration architecture for Named Data Networking (NDN).

## Quick Setup

To compile and install the data plane:
```shell
./build.sh
./install.sh
```

Run the L2 switch:
```shell
./run_switchd.sh
```

Add and enable ports:
```shell
ucli
pm
port-add -/0 100G NONE
an-set -/- 2
port-enb -/-
```

