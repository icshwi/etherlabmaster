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
# Date    : Tuesday, April 30 02:20:36 CEST 2019
# version : 0.0.2
#

DKMS:=/usr/sbin/dkms


autoconf:
	touch ChangeLog
	autoreconf -i
	./configure $(E3_ETHERLAB_CONF_OPTIONS) --prefix=$(E3_ETHERLAB_INSTALL_LOCATION)


build: 
	make


install: build
	make install


uninstall:
	make uninstall



modules: 
	make modules


modules_install: 
	make modules_install
	$(QUIET) depmod --quick

dkms_build:
	$(DKMS) build -m $(E3_MODULE_NAME) -v $(E3_MODULE_VERSION)


dkms_add:
	$(DKMS) add -m $(E3_MODULE_NAME) -v $(E3_MODULE_VERSION)

dkms_remove:
	$(DKMS) remove -m $(E3_MODULE_NAME) -v $(E3_MODULE_VERSION) --all


dkms_install:
	$(DKMS) install -m $(E3_MODULE_NAME) -v $(E3_MODULE_VERSION) --force
	$(QUIET) depmod --quick

dkms_uninstall:
	$(DKMS) uninstall -m $(E3_MODULE_NAME) -v $(E3_MODULE_VERSION)
	$(QUIET) depmod --quick

clean:
	make clean


.PHONY: autoconf build install uninstall modules modules_install modules_uninstall clean

