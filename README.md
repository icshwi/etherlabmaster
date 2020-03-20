etherlabmaster
======

[![Action Main Status](https://github.com/icshwi/etherlabmaster/workflows/Main%20Repo/badge.svg)](https://github.com/icshwi/etherlabmaster/actions?workflow=Main+Repo)
[![Action Patchset Status](https://github.com/icshwi/etherlabmaster/workflows/Patchset%20Repo/badge.svg)](https://github.com/icshwi/etherlabmaster/actions?workflow=Patchset+Repo)

Configuration Environment for EtherLab IgH EtherCAT Master at https://sourceforge.net/projects/etherlabmaster/


## Notice and Warning
* This is **NOT** a web application, **NOT** an Apps for phones, **NOT** a cloud application.
* If the system has already the etherlab master kernel configuration, please don't use this before cleaning up all existent configuration.
* If one would like to use it with https://github.com/epics-modules/ecmc, one should use it on **Intel** architecture. The `ecmc` needs `--enable-cycles = YES` in order to use CPU timestamp counter. However, test have been initiated on ARM, see section below on Raspberry pi for more info.

## Role
In order to download, install, setup all relevant components (system library, kernel module, ethercat configuration, and systemd service), one should do many steps manually. This repository was designed for the easy-to-reproducible environment for EtherLab EtherCAT Master. With the following steps, one can run the EtherCAT Master on one dedicated Ethernet port within CentOS, RedHat, Ubuntu, and Debian OSs.

### Packages
One should install relevant packages before trying to setup `etherlabmaster`. After this, one should reboot the system once in order to match the running kernel version and kernel header files. If one has its own customized kernel version, one should configure them properly. The following guide is only valid for a **Vanilla Kernel** of Debian or CentOS distributions.

* Debian
  ```
  apt install -y linux-headers-$(uname -r) build-essential libtool automake tree dkms
  ```
 
* CentOS
  ```
  yum groupinstall 'Development Tools'
  yum install -y kernel-devel tree dkms
  ```

## Rules

Before the setup the etherlab master, one should define the **DEDICATED** network port which one would like to use as the EtherCAT Master, and which is **NOT** the running network port. Please look at scripts/ethercatmaster.conf, and enable one and disable all others to match the device which one would like to use. With the following command, without changing git status, one can set the master device in the etherlab master configuration:

```sh
etherlabmaster (master)$ echo "ETHERCAT_MASTER0=enp0s25" > ethercatmaster.local
```
The local file will be used to override the ETHERCAT_MASTER0 variable defined in scripts/ethercatmaster.conf.


One should check the autoconf configuration options, which are relevant for our application currently. These options are defined in `configure/CONFIG_OPTIONS` are defined when `make build` or `make autoconf` by using `E3_EHTERLAB_CONF_OPTIONS`. One can see them all via `make showopts` such as
```
$ make showopts

>>>>  Configuration Options Variables   <<<<

E3_EHTERLAB_CONF_OPTIONS is defined as follows:

--enable-generic --disable-8139too --disable-e100 --disable-e1000 --disable-e1000e --disable-igb --disable-r8169 --disable-ccat --enable-static=no --enable-shared=yes --enable-eoe=no --enable-cycles=no --enable-hrtimer=no --enable-regalias=no --enable-tool=yes --enable-userlib=yes --enable-sii-assign=yes --enable-rt-syslog=yes

WITH_DEV_8139TOO = NO
WITH_DEV_CCAT = NO
WITH_DEV_E100 = NO
WITH_DEV_E1000 = NO
WITH_DEV_E1000E = NO
WITH_DEV_GENERIC = YES
WITH_DEV_IGB = NO
WITH_DEV_R8169 = NO

ENABLE_CYCLES = NO
ENABLE_EOE = NO
ENABLE_HRTIMER = NO
ENABLE_REGALIAS = NO
ENABLE_RT_SYSLOG = YES
ENABLE_SII_ASSIGN = YES
ENABLE_STATIC = NO
ENABLE_TOOL = YES
ENABLE_USERLIB = YES
```
The most options are default, but we would like to keep the Site-specific options consistently. Note that the current implementation is so-called *work in progress* because of the dkms configuration.

One can override each option as follows:
```
echo "WITH_DEV_GENERIC = NO"  > configure/CONFIG_OPTIONS.local
echo "WITH_DEV_E1000E = YES" >> configure/CONFIG_OPTIONS.local
echo "ENABLE_STATIC = YES"   >> configure/CONFIG_OPTIONS.local
```
, where `>>` is the important thing if one would like to override more than one option.


Be ready to do the following commands in the specific order:

```sh
etherlabmaster (master)$ make init
```

* Select the proper options

* Check the options

```
etherlabmaster (master)$ make showopts
```
* `make build` calls `make autoconf` internally. However, if one would like to change the option after `make init`, one should run `make autoconf` whenever the options are changed.

```
etherlabmaster (master)$ make build
etherlabmaster (master)$ make install
```

Kernel modules are built via dkms. Note that the system should install the `dkms` package first.

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
etherlabmaster (master)$ make setup_clean
etherlabmaster (master)$ make conf
etherlabmaster (master)$ make dkms_uninstall
etherlabmaster (master)$ make dkms_remove

```

## Steps

#### `make init`
* Download the main etherlabmaster-code from sf.net
* Switch to Revison version below. We are using the following master revision number as the starting point
* Apply the Site Specific local patch files. See Ref [1].

```
#jhlee@qweak: etherlabmaster-code (master)$ hg heads
#changeset:   2296:0c011dc6dbc4
#branch:      stable-1.5
#tag:         tip
#user:        Florian Pose
#date:        Fri Jun 14 12:42:52 2019 +0200
#summary:     Fixed memory leak concerning library ecrt_master_deactivate().

```

#### `make autoconf`
* One should run this every time when the CONFIG_OPTIONS is changed.

#### `make build`
* Ethercat program compilation

#### `make install`
* Ethercat program (configuration, lib, and others) installation

#### `make dkms_add`
* dkms add

#### `make dkms_build`
* dkms build via dkms

#### `make dkms_install`
* Kernel modules installation via dkms

#### `make setup`

* Activate the EtherCAT master Network Port
* Setup the dkms systemd service
* Setup the ethercat systemd service
* Put the UDEV rule to allow a user to access the ethercat master port
* Put the UDEV rule to do *unmanaged*able on the ethercat master port by NetworkManager
* Create the symbolic link for the ethercat executable command
* Put the lib path in the global ld configuration path


#### `make deinit`
* Remove the downloaded etherlabmaster-code path


## Etherlab master patchset 20180622

One can use the unofficial patchset maintained by Gavin Lambert [2] with the local patch file [3], because the unofficial patchset is *ONLY* valid for `--enable-eoe=yes`.  The local `make patch` is executed after all patchset. So we don't need to run it individually.


```sh
etherlabmaster (master)$ make patchset
```

* Select the proper options

* Check the options

```
etherlabmaster (master)$ make showopts
```


```sh
etherlabmaster (master)$ make build
etherlabmaster (master)$ make install
```

Kernel modules are built via dkms. Note that the system should install the `dkms` package first.

```sh
etherlabmaster (master)$ make dkms_add
etherlabmaster (master)$ make dkms_build
etherlabmaster (master)$ make dkms_install
etherlabmaster (master)$ make setup
```

## Identify the Network Card Driver

It uses the default variable which one has to set as `ETHERCAT_MASTER0` at the beginning in order to find the proper driver, which one may select it properly.
```
$ make show_netdrv
/sys/class/net/enp0s25/device/uevent:DRIVER=e1000e
```
Once the `e1000e` native driver is loaded within the Linux kernel, one cannot see the netdrv anymore, because the device which one allocate is not the network device anymore.

## Troubleshooting

[Troubleshooting](TROUBLESHOOT.md)


### References and Comments

#### [1] *make patch*  

* We would like to keep ethercat.conf file within $PREFIX/etc path.  [See the patch file 1](./patch/Site/use_prefix_for_ethercat_conf_path.p0.patch)
* We need to modify the default systemd configuration file in order to use it with dkms service.  [See the patch file 2](./patch/Site/after_dkms_service_patch.p0.patch)

#### [2] http://hg.code.sf.net/u/uecasm/etherlab-patches  


#### [3] [patch/patchset/000.patchset_optional_eoe.p0.patch](./patch/patchset/000.patchset_optional_eoe.p0.patch)


#### Comments
* It is still unclear how to build `ethercat.conf` if we have more than one devices now.

## CentOS7 with the NATIVE e1000e driver

### Notice and Warning
* This is **NOT** for the generic driver, **BUT** for the **NATIVE** e1000e driver. If one would like to use the generic one, it is not necessary to follow this step. If one doesn't know what difference is, one should go the generic one. 

Due to `rh_kabi.h`, we cannot compile e1000e native driver the default kernel 3.10. Thus, it needs the special patch file for this purpose. Some functionalities are limited and especially related with kernel log and a network device usage statistics. Both of them are no critical things for the ethercat application. The additional makefile rule command `make centos7_patch` is necessary before `make dkms_add`. The full commands are

```
make init
make centos7_patch
make build
make install
make dkms_add
make dkms_build
make dkms_install
make setup
```


## Beckhoff CCAT FPGA Kernel Mode Driver [1] 

### Install Beckhoff CCAT Kernel Driver 

Please follow the README file in https://github.com/jeonghanlee/CCAT-env
Make sure the kernel drivers are loaded 
```
lsmod |grep ccat
ccat_update            16384  0
ccat_systemtime        16384  0
ccat_sram              16384  0
ccat_gpio              16384  0
ccat_netdev            20480  0
ccat                   16384  2 ccat_sram,ccat_update

```

### Etherlabmaster code 

The etherlab master needs the following patch file in [2]. This repository has the copied version of this file with the hash id `bc9e28f` ( 2019-11-05 ) in `patch/CCAT`. For further information, please look at the header of the patch file. In addition, `ccat_netdev.ko` cannot be removed if it is loaded. With that kernel module, we cannot insert `ec_ccat_netdev.ko`. Thus, we need to have another patch file [3]. Please remember that one should the Beckhoff CCAT first [1,4], then follow the commands. 
 
### Commands

* Set the `ETHERCAT_MASTER0` (This should be verified!!!)

```
echo "ETHERCAT_MASTER0=enp0s25" > ethercatmaster.local
```

* Make sure that there is no existent etherlabmaster EtherCAT kernel



```
make init
echo "WITH_DEV_GENERIC = NO"  > configure/CONFIG_OPTIONS.local
echo "WITH_DEV_CCAT = YES" >> configure/CONFIG_OPTIONS.local
make ccat_patch
make build
make install
make dkms_add
make dkms_build
make dkms_install
make setup
```

### Few interesting command results

```
$ echo "WITH_DEV_GENERIC = NO"  > configure/CONFIG_OPTIONS.local
$ echo "WITH_DEV_CCAT = YES" >> configure/CONFIG_OPTIONS.local
$ make showopts

>>>>  Configuration Options Variables   <<<<

E3_EHTERLAB_CONF_OPTIONS is defined as the follows:

--disable-generic --disable-8139too --disable-e100 --disable-e1000 --disable-e1000e --disable-igb --disable-r8169 --enable-ccat_netdev --enable-static=yes --enable-shared=yes --enable-eoe=no --enable-cycles=yes --enable-hrtimer=no --enable-regalias=no --enable-tool=yes --enable-userlib=yes --enable-sii-assign=yes --enable-rt-syslog=yes

WITH_PATCHSET = NO

WITH_DEV_8139TOO = NO
WITH_DEV_CCAT = YES
WITH_DEV_E100 = NO
WITH_DEV_E1000 = NO
WITH_DEV_E1000E = NO
WITH_DEV_GENERIC = NO
WITH_DEV_IGB = NO
WITH_DEV_R8169 = NO

ENABLE_CYCLES = YES
ENABLE_EOE = NO
ENABLE_HRTIMER = NO
ENABLE_REGALIAS = NO
ENABLE_RT_SYSLOG = YES
ENABLE_SII_ASSIGN = YES
ENABLE_STATIC = YES
ENABLE_TOOL = YES
ENABLE_USERLIB = YES

make ccat_patch

Patching etherlabmaster-code with the CCAT patch file : /home/jhlee/ics_gitsrc/etherlabmaster/patch/CCAT/0001-convert-ccat-to-mfd.patch
patching file configure.ac
Hunk #1 succeeded at 539 (offset -1 lines).
Hunk #2 succeeded at 548 (offset -1 lines).
patching file devices/ccat/Kbuild.in
patching file devices/ccat/Makefile.am
patching file devices/ccat/gpio.c
patching file devices/ccat/module.c
patching file devices/ccat/module.h
patching file devices/ccat/netdev.c
patching file devices/ccat/sram.c
patching file devices/ccat/update.c
patching file devices/ccat/update.h
patching file script/ethercat.conf
patching file script/ethercatctl.in
patching file script/sysconfig/ethercat
```


```
# systemctl restart ethercat

# lsmod  |grep ccat
ec_ccat_netdev         24576  0
ec_master             331776  1 ec_ccat_netdev
ccat_update            16384  0
ccat_systemtime        16384  0
ccat_sram              16384  0
ccat_gpio              16384  0
ccat                   16384  2 ccat_sram,ccat_update


```
## Installing on Raspbian
Tests have been performed on:
- Raspberry-pi 4b running Raspbian version 4.19.97-v7l+ (ARM arch).
- generic driver

RT-patches have not been tested yet. WIP..

Prepare:
```
# Tools
$ sudo apt install -y  build-essential libtool automake tree dkms
# Hg
$ sudo apt-get install mercurial
# Kernel headers are needed:
$ sudo apt install raspberrypi-kernel-headers
```
Note: TSC is not available for ARM so the option "ENABLE_CYCLES=NO" is needed.
```
# !!!!!!IMPORTANT TSC not availbe in ARM (Set ENABLE_CYCLES=NO)!!!!!!! 
$ echo "ENABLE_CYCLES = NO" > configure/CONFIG_OPTIONS.local
```
Install etherlab master:
```
$ git clone https://github.com/icshwi/etherlabmaster
$ cd etherlabmaster
$ make init
# !!!!!!IMPORTANT TSC not availbe in ARM (Set ENABLE_CYCLES=NO)!!!!!!! 
$ echo "ENABLE_CYCLES = NO" > configure/CONFIG_OPTIONS.local
$ make build
$ make install
$ echo "ETHERCAT_MASTER0=eth0" > ethercatmaster.local
$ make dkms_add
$ make dkms_build
$ make dkms_install
$ make setup
# Reboot or start manually
$ sudo systemctl start ethercat
```
## References
[1] https://github.com/Beckhoff/CCAT

[2] https://github.com/Beckhoff/CCAT/blob/master/etherlab-patches/0001-convert-ccat-to-mfd.patch

[3] https://github.com/icshwi/etherlabmaster/blob/devel/ccat_netdev/patch/CCAT/0002-remove-beckhoff-ccat_netdev-if-exists.patch

[4] https://github.com/jeonghanlee/CCAT-env
