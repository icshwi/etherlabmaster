etherlabmaster
======
Configuration Environment for EtherLab EtherCAT Master at https://sourceforge.net/projects/etherlabmaster/

## Role
In order to download, install, setup all relevant components (system library, kernel module, ethercat configuration, and systemd service), one should do many steps manually. This repository was designed for the easy-to-reproducible enviornment for EtherLab EtherCAT Master. With the following steps, one can run the EtherCAT Master on one dedicated ethernet port within CentOS and Debian OSs.



## Rules

Before the setup the etherlab master, one should define the network port which one would like to use as the EtherCAT Master. Please look at scripts/ethercatmaster.conf, and enable one and disable all others to match the device which one would like to use. With the following command, without changing git status, one can set the master device in the etherlab master configuration:

```
etherlabmaster (master)$ echo "ETHERCAT_MASTER0=eth0" > ethercatmaster.local
```
The local file will be used to override the ETHERCAT_MASTER0 variable defined in scripts/ethercatmaster.conf.

Be ready to do the following commands in the specific order:

```
etherlabmaster (master)$ make init
etherlabmaster (master)$ make patch
etherlabmaster (master)$ make build
etherlabmaster (master)$ make install
```

Kernel modules are built via dkms

```
etherlabmaster (master)$ make dkms_add
etherlabmaster (master)$ make dkms_build
etherlabmaster (master)$ make dkms_install
etherlabmaster (master)$ make setup
```

One should start the ethercat via
```
etherlabmaster (master)$ sudo systemctl start ethercat
```
And one can check the master status as follows:
```
etherlabmaster (master)$ ethercat master
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
* We would like to keep ethercat.conf file within $PREFIX/etc path
* [See the patch file](./patch/Site/use_prefix_for_ethercat_conf_path.p0.patch)

### make build
* Ethercat program compilation

### make install
* Ethercat program (configuration, lib, and others) installation

### make dkms_add
* dkms add

### make dkms_build
* dkms build via dkms


### make dkms_install
* Kernel modules installation via dkms

### make setup

* Activate the EtherCAT master Network Port
* Setup the dkms systemd service
* Setup the ethercat systemd service
* Put the UDEV rule to allow an user to access the ethercat master port
* Create the symbolic link for the ethercat executable command
* Put the lib path in the global ld configuration path
