#!/bin/bash
#
#  Copyright (c) 2018 - 2019 Jeong Han Lee
#  Copyright (c) 2018 - 2019 European Spallation Source ERIC
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
# Author  : Jeong Han Lee
# email   : jeonghan.lee@gmail.com
# Date    : Saturday, October 12 16:45:23 CEST 2019
# version : 0.0.3

declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="${SC_SCRIPT%/*}"

declare -gr SUDO_CMD="sudo";

EXIST=1
NON_EXIST=0


ECAT_DKMS_SYSTEMD=dkms.service
ECAT_MASTER_SYSTEMD=ethercat.service
ECAT_MASTER_CONF=ethercat.conf
SD_UNIT_PATH_DEBIAN=/etc/systemd/system
SD_UNIT_PATH_CENTOS=/usr/lib/systemd/system



ECAT_KMOD_NAME="ethercat"
ECAT_KMOD_MASTER_NAME="master"
ECAT_KMOD_GENERIC_NAME="generic"



function checkIfVar()
{

    local var=$1
    local result=""
    if [ -z "$var" ]; then
	result=$NON_EXIST
	# doesn't exist
    else
	result=$EXIST
	# exist
    fi
    echo "${result}"
}

## if [[ $(checkIfFile "${release_file}") -eq "$NON_EXIST" ]]; then
#   NON_EXIT
## fi

function checkIfFile
{
    local file=$1
    local result=""
    if [ ! -e "$file" ]; then
	result=$NON_EXIST
	# doesn't exist
    else
	result=$EXIST
	# exist
    fi
    echo "${result}"	 
};



function find_dist
{

    local dist_id dist_cn dist_rs PRETTY_NAME
    
    if [[ -f /usr/bin/lsb_release ]] ; then
     	dist_id=$(lsb_release -is)
     	dist_cn=$(lsb_release -cs)
     	dist_rs=$(lsb_release -rs)
     	echo $dist_id ${dist_cn} ${dist_rs}
    else
     	eval $(cat /etc/os-release | grep -E "^(PRETTY_NAME)=")
	echo ${PRETTY_NAME}
    fi

 
}


function get_macaddr
{
    local dev=${1};
    cat /sys/class/net/${dev}/address
}




function clean_setup_systemd
{
    printf ">>> Cleaning the setup the systemd %s in %s\n" "${ECAT_MASTER_SYSTEMD}" "${SD_UNIT_PATH}"

    local file=${SD_UNIT_PATH}/${ECAT_MASTER_SYSTEMD}
    ${SUDO_CMD} systemctl stop ${ECAT_MASTER_SYSTEMD};
    ${SUDO_CMD} systemctl disable ${ECAT_MASTER_SYSTEMD};
    if [[ $(checkIfFile "${file}") -eq "EXIST" ]]; then
	${SUDO_CMD} rm -rf ${file}
    fi
    ${SUDO_CMD} systemctl daemon-reload;
    
}


function clean_setup_dkms_systemd
{
    printf ">>> Cleaning the setup the systemd %s in %s\n" "${ECAT_DKMS_SYSTEMD}" "${SD_UNIT_PATH}"

    local file=${SD_UNIT_PATH}/${ECAT_DKMS_SYSTEMD}
    ${SUDO_CMD} systemctl stop ${ECAT_DKMS_SYSTEMD};
    ${SUDO_CMD} systemctl disable ${ECAT_DKMS_SYSTEMD};
    if [[ $(checkIfFile "${file}") -eq "EXIST" ]]; then
	${SUDO_CMD} rm -rf ${file}
    fi
    ${SUDO_CMD} systemctl daemon-reload;
 
    printf "\n"
    
}

# arg1 : KMOD NAME
# arg2 : target_rootfs, if exists
function clean_put_udev_rule
{

    local kmod_name=${1}
    local target_rootfs=${2}
    local udev_rules_dir="${target_rootfs}/etc/udev/rules.d"
    local rule=""
    local target=""
 
    case "$kmod_name" in     
	${MRF_KMOD_NAME})
	    rule="KERNEL==\"uio*\", ATTR{name}==\"mrf-pci\", MODE=\"0${KMOD_PERMISSON}\"";
	    target="${udev_rules_dir}/99-${MRF_KMOD_NAME}ioc2.rules";
	    ;;
	${SIS_KMOD_NAME})
	    rule="KERNEL==\"sis8300-[0-9]*\", NAME=\"%k\", MODE=\"0${KMOD_PERMISSON}\"";
	    target="${udev_rules_dir}/99-${SIS_KMOD_NAME}.rules";
	    ;;
	${ECAT_KMOD_NAME})
	    rule="KERNEL==\"EtherCAT[0-9]*\", SUBSYSTEM==\"EtherCAT\", MODE=\"0${KMOD_PERMISSON}\"";
	    target="${udev_rules_dir}/99-${ECAT_KMOD_NAME}.rules";
	    ;;
	*)
	    # no rule, but create a dummy file
	    rule=""
	    target="${udev_rules_dir}/99-${kmod_name}.rules";
	    ;;
    esac

    if [[ $(checkIfFile "${target}") -eq "EXIST" ]]; then
	printf ">>> Clean the udev rule :%s.\n" "$target";
	printf "    "
	${SUDO_CMD} rm -rf ${target}
    fi
  
}


# arg1 : device name
# arg2 : target_rootfs, if exists
function clean_udev_rule_for_unmanaged
{
    local target_rootfs=${1}; shift;
    local udev_rules_dir="${target_rootfs}/etc/udev/rules.d"
    local target="";

    target="${udev_rules_dir}/00-unmanaged-device-by-nm.rules";

    if [[ $(checkIfFile "${target}") -eq "EXIST" ]]; then
	printf "\n>>> Clean the udev rule :%s.\n" "$target";
	printf "    "
	${SUDO_CMD} rm -rf ${target}
    fi
}


function reload_trigger_udev_rule
{

    if [ -f /bin/udevadm ]; then
	printf "\n>>> Reload udev rules, and trigger it\n"
	${SUDO_CMD} /bin/udevadm control --reload-rules
    else
	printf ">>> No udevadm found. Reboot the system to apply new rules!\n"
    fi
    
}


function usage
{
    {
	echo "";
	echo "Usage    : $0 [-t <etherlab master installation path>] " ;
	echo "";
	echo "               -t : mandatory"
	echo ""
	
    } 1>&2;
    exit 1; 
}


## Determine CentOS or Debian, because systemd path is different

dist="$(find_dist)"

case "$dist" in
    *Debian*)
	SD_UNIT_PATH=${SD_UNIT_PATH_DEBIAN}
	;;
    *Ubuntu*)
	SD_UNIT_PATH=${SD_UNIT_PATH_DEBIAN}
	;;
    *Raspbian*)
	SD_UNIT_PATH=${SD_UNIT_PATH_DEBIAN}
	;;
    *CentOS*)
	SD_UNIT_PATH=${SD_UNIT_PATH_CENTOS}
	;;
    *RedHat*)
	SD_UNIT_PATH=${SD_UNIT_PATH_CENTOS}
	;;
    *)
	printf "\n";
	printf "Doesn't support the detected $dist\n";
	printf "Please contact jeonghan.lee@gmail.com\n";
	printf "\n";
	exit;
	;;
esac

${SUDO_CMD} -v

clean_setup_dkms_systemd
clean_setup_systemd
clean_put_udev_rule "${ECAT_KMOD_NAME}"
# clean_udev_rule_for_unmanaged;

reload_trigger_udev_rule

CLEAN_TARGET=/usr/bin/ethercat
if [[ $(checkIfFile "${CLEAN_TARGET}") -eq "EXIST" ]]; then
    ${SUDO_CMD} rm -rf ${CLEAN_TARGET}

fi

CLEAN_TARGET=/etc/ld.so.conf.d/e3_ethercat.conf
if [[ $(checkIfFile "${CLEAN_TARGET}") -eq "EXIST" ]]; then
    ${SUDO_CMD} rm -rf ${CLEAN_TARGET}
    ${SUDO_CMD} ldconfig 
fi


