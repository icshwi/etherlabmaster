#
#  Copyright (c) 2019         Jeong Han Lee 
#  Copyright (c) 2018 - 2019  European Spallation Source ERIC
#
#  The program is free software: you can redistribute
#  it and/or modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation, either version 2 of the
#  License, or any newer version.
#
#  This program is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
#  more details.
#
#  You should have received a copy of the GNU General Public License along with
#  this program. If not, see https://www.gnu.org/licenses/gpl-2.0.txt
#
# 
# Author  : Jeong Han Lee
# email   : jeonghan.lee@gmail.com
# Date    : Monday, May  6 21:57:44 CEST 2019
# version : 0.0.3
#

#DKMS:=/usr/sbin/dkms
#DKMS:=/home/jhlee/private_gitsrc/dkms

autoconf:
	$(QUIET) touch ChangeLog
	$(QUIET) autoreconf --force --install -v
	./configure $(E3_ETHERLAB_CONF_OPTIONS) --prefix=$(E3_ETHERLAB_INSTALL_LOCATION)


build: 
	make


install: build
	make install


uninstall:
	make uninstall


modules: 
	make modules

modules_clean: 
	make modules clean

modules_install: 
	make modules install
	$(QUIET) depmod -a

modules_uninstall: 
	make modules uninstall
	$(QUIET) depmod -a


dkms_build:
	$(DKMS) build -m $(E3_MODULE_NAME) -v $(E3_MODULE_VERSION)
#	$(DKMS) build -m $(E3_MODULE_NAME) -v $(E3_MODULE_VERSION) --verbose

dkms_add:
	$(DKMS) add -m $(E3_MODULE_NAME) -v $(E3_MODULE_VERSION)

dkms_remove:
	$(DKMS) remove -m $(E3_MODULE_NAME) -v $(E3_MODULE_VERSION) --all


dkms_install:
	$(DKMS) install -m $(E3_MODULE_NAME) -v $(E3_MODULE_VERSION) --force
	$(QUIET) depmod -a

dkms_uninstall:
	$(DKMS) uninstall -m $(E3_MODULE_NAME) -v $(E3_MODULE_VERSION)
	$(QUIET) depmod -a

clean:
	make clean


.PHONY: autoconf build install uninstall modules modules_install modules_uninstall clean dkms_build dkms_add dkms_remove dkms_install dkms_uninstall


