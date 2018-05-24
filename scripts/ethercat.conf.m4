dnl   PLEASE LOOK AT /opt/etherlab/etc/ethercat.conf
dnl
dnl   Set the cross compiler target archs
dnl   $ m4  -D_CROSS_COMPILER_TARGET_ARCHS=linux-ppc64e6500 config_site.m4

dnl
dnl
ifdef(`_MASTER0_DEVICE',
	`MASTER0_DEVICE="_MASTER0_DEVICE"',
	`MASTER0_DEVICE="" ')
	
ifdef(`_MASTER1_DEVICE',
	`MASTER1_DEVICE ="_MASTER1_DEVICE"',
	`#MASTER1_DEVICE = ')
	
ifdef(`_MASTER0_BACKUP',
	`MASTER0_BACKUP="_MASTER0_BACKUP"',
	`#MASTER0_BACKUP=')
	
ifdef(`_DEVICE_MODULES', 
	`DEVICE_MODULES="_DEVICE_MODULES"',
	`DEVICE_MODULES=""')
	
