#
#  Copyright (c) 2018 - Present  European Spallation Source ERIC
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
# Date    : Wednesday, July 25 23:31:31 CEST 2018
# version : 0.0.1
#

DKMS:=/usr/sbin/dkms


autoconf:
	$(QUIET) touch ChangeLog
	$(QUIET) autoreconf -i
	./configure $(E3_ETHERLAB_CONF_OPTIONS) --prefix=$(E3_ETHERLAB_INSTALL_LOCATION)


build: 
	$(MAKE)


install: build
	$(MAKE) install


uninstall:
	$(MAKE) uninstall


modules: 
	$(MAKE) modules


modules_install: 
	$(MAKE) modules_install
	depmod --quick

dkms_build:
	$(DKMS) build  -m $(E3_MODULE_NAME) -v $(E3_MODULE_VERSION) 

dkms_add:
	$(DKMS) add    -m $(E3_MODULE_NAME) -v $(E3_MODULE_VERSION)

dkms_remove:
	$(DKMS) remove -m $(E3_MODULE_NAME) -v $(E3_MODULE_VERSION) --all


dkms_install:
	$(DKMS) install  -m $(E3_MODULE_NAME) -v $(E3_MODULE_VERSION)
	depmod --quick

dkms_uninstall:
	$(DKMS) uninstall -m $(E3_MODULE_NAME) -v $(E3_MODULE_VERSION)
	depmod --quick

clean:
	$(MAKE) clean


.PHONY: autoconf build install uninstall modules modules_install modules_uninstall clean

