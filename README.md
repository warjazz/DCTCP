# DCTCP Assignment
Adapted from https://github.com/mininet/mininet-tests

# Kernel and Mininet Installation

## Dependecies

- Ubuntu Server 12.04.0 i386 (http://old-releases.ubuntu.com/releases/12.04.0/ubuntu-12.04-alternate-i386.iso)

## Instructions to install DCTCP kernel:

```
su -
mv linux-* /usr/src
cd /usr/src
tar -xjf linux-headers-3.2.18-dctcp.tar
dpkg -i linux-image-3.2.18-dctcp_3.2.18-dctcp-10.00.Custom_amd64.deb
dpkg -i linux-headers-3.2.18-dctcp_3.2.18-dctcp-10.00.Custom_amd64.deb
update-grub2
reboot
```

## Examine the installation

 - After reboot, check if DCTCP has been correctly installed:
  ```sysctl -a | grep tcp_dctcp```

## Install mininet and other tools

 - If a package cannot be installed, find out how to install it by source code!
  ```sudo apt-get install mininet tcpdump bwm-ng openssh-server cgroup-bin python-termcolor```
 
 - Reconfigure openvswitch (only if you haven't done it when installing mininet)
  ```sudo dpkg-reconfigure openvswitch-datapath-dkms```

## Prepare for the mininet

 - Create symbolic link for openvswitch controller
  ```
  cd /usr/bin
  sudo ln /usr/bin/ovs-controller /usr/bin/controller
 ```
 
 - Restart all controllers
```
  ps aux | grep osv-
  sudo kill -9 <all osv-* processes>
  sudo service openvswitch-switch start
```

- Check if Mininet is working fine
```
  sudo reboot
  sudo mn --link tc,bw=100 --test iperf
```

# Instructions to the DCTCP experiment:

 - To run the dctcp experiments:
```
  cd dctcp_assignment
  ./run-dctcp.sh
```

 - You can change the running mode (TCP, ECN, DCTCP) by editing the run-dctcp.sh file.

 - All the outputs and plots are stored in [a]-n[b]-bw[c] directories where [a] is the running mode, 
    [b] is the number of hosts and [c] is the network throughput.
