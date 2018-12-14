etherlabmaster
======
Configuration Environment for EtherLab IgH EtherCAT Master at https://sourceforge.net/projects/etherlabmaster/

## Role
In order to download, install, setup all relevant components (system library, kernel module, ethercat configuration, and systemd service), one should do many steps manually. This repository was designed for the easy-to-reproducible environment for EtherLab EtherCAT Master. With the following steps, one can run the EtherCAT Master on one dedicated Ethernet port within CentOS, RedHat, Ubuntu, and Debian OSs.


## Notice
* It may work with only **Generic EtherCAT Device Driver**. With limited resources, we cannot test this repository with other device drivers. And pull requests for other supports are always welcome!
* If the system has already the etherlab master kernel configuration, please don't use this before cleaning up all existent configuration.

## Rules

Before the setup the etherlab master, one should define the network port which one would like to use as the EtherCAT Master. Please look at scripts/ethercatmaster.conf, and enable one and disable all others to match the device which one would like to use. With the following command, without changing git status, one can set the master device in the etherlab master configuration:

```sh
etherlabmaster (master)$ echo "ETHERCAT_MASTER0=enp0s25" > ethercatmaster.local
```
The local file will be used to override the ETHERCAT_MASTER0 variable defined in scripts/ethercatmaster.conf.


One should check the compiling options ```E3_ETHERLAB_CONF_OPTIONS``` in configure/CONFIG_MODULE. The default options which ESS uses are 

```
E3_ETHERLAB_CONF_OPTIONS = --disable-8139too --enable-generic --enable-sii-assign=yes --enable-eoe=no
```
The entire ```E3_ETHERLAB_CONF_OPTIONS``` can be override with the "git-ignored" file as follows:

```
echo "E3_ETHERLAB_CONF_OPTIONS = --disable-8139too --enable-generic" > configure/CONFIG_MODULE.local
```

Be ready to do the following commands in the specific order:

```sh
etherlabmaster (master)$ make init
etherlabmaster (master)$ make patch
etherlabmaster (master)$ make build
etherlabmaster (master)$ make install
```

Kernel modules are built via dkms. Note that the system should install the ```dkms``` package first. 

```sh
etherlabmaster (master)$ make dkms_add
etherlabmaster (master)$ make dkms_build
etherlabmaster (master)$ make dkms_install
etherlabmaster (master)$ make setup
```


One should start the ethercat via
```sh
etherlabmaster (master)$ sudo systemctl start ethercat
```
And one can check the master status as follows:
```sh
etherlabmaster (master)$ ethercat master
```


In order to remove them and clean the configuration

```sh
etherlabmaster (master)$ sudo systemctl stop ethercat
etherlabmaster (master)$ sudo systemctl disable ethercat
etherlabmaster (master)$ make dkms_uninstall
etherlabmaster (master)$ make dkms_remove
etherlabmaster (master)$ make setup_clean
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
* We would like to keep ethercat.conf file within $PREFIX/etc path.  [See the patch file 1](./patch/Site/use_prefix_for_ethercat_conf_path.p0.patch)
* We need to modify the default systemd configuration file in order to use it with dkms service.  [See the patch file 2](./patch/Site/after_dkms_service_patch.p0.patch)

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


### make deinit
* Remove the downloaded etherlabmaster-code path


## Beckhoff CCAT FPGA Kernel Mode Driver
* https://github.com/jeonghanlee/CCAT-env

## Troubleshooting

### make build error

* need to install proper package, and reboot the system once in order to match the running kernel version and installed kernel source all together. 

```
configure: error: Failed to find Linux sources. Use --with-linux-dir!
make[1]: *** [autoconf] Error 1
```


