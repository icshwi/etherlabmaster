
e3-etherlabmaster  
======
ESS Site-specific EPICS module : etherlabmaster


## Rules

Please execute one by one in order. 


```
$ make init
$ make patch
$ make build
$ make install
$ make modules_build
$ make modules_install
```

Before the setup the etherlab master, one should define the network port which one would like to use as the EtherCAT Master.
Please look at scripts/ethercatmaster.conf, and enable one and disable all others to match the device which one would like to use. Then,

```
$ make setup
```

One should start the ethercat via
```
$ sudo systemctl start ethercat
```
And one can check the master status as follows:
```
$ ethercat master
```


## Steps

### make init
* Download the main etherlabmaster-code from sf.net
* Switch to Revison 9e65f7. We are using the following master revision number as the starting point  
```
[9e65f7] (stable-1.5, tip) by Florian Pose 
Fixed scheduler settings in dc_user example; use CLOCK_MONOTONIC.
2018-02-13 16:16:01 
```
### make patch
* We need this!

### make build
* Ethercat program compilation

### make install
* Ethercat program (configuration, lib, and others) installation

### make modules_build
* Kernel modules compiliation

### make modules_install
* Kernel modules installation

### make setup

* Activate the EtherCAT master Network Port
* Setup the ethercat systemd service
* Put the UDEV rule to allow an user to access the ethercat master port
* Create the symbolic link for the ethercat executable command
* Put the lib path in the global ld configuration path
