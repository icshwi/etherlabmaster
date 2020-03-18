#!/bin/bash
#
#  Copyright (c) 2018 - 2019 Jeong Han Lee
#  Copyright (c) 2018        Ronald Mercado 
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
#         : Ronald Mercado 
# email   : jeonghan.lee@gmail.com
#
# Date    : Saturday, October 12 16:42:43 CEST 2019
#
# version : 0.1.1

declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="${SC_SCRIPT%/*}"

declare -gr SUDO_CMD="sudo";

EXIST=1
NON_EXIST=0

set -a
. ${SC_TOP}/ethercatmaster.conf
if [ -r ${SC_TOP}/../ethercatmaster.local ]; then
    printf ">>> We've found the local configuration file.\n";
    printf "    The original ETHERCAT_MASTER0 = %s\n" "${ETHERCAT_MASTER0}"
    . ${SC_TOP}/../ethercatmaster.local
    printf "    will be overriden with ETHERCAT_MASTER0 = %s\n\n" "${ETHERCAT_MASTER0}"
    
fi
. ${SC_TOP}/device_modules.conf
set +a

ECAT_DKMS_SYSTEMD=dkms.service
ECAT_MASTER_SYSTEMD=ethercat.service
ECAT_MASTER_CONF=ethercat.conf
SD_UNIT_PATH_DEBIAN=/etc/systemd/system
SD_UNIT_PATH_CENTOS=/usr/lib/systemd/system



ECAT_KMOD_NAME="ethercat"
ECAT_KMOD_MASTER_NAME="master"

KMOD_PERMISSON="666"


ECAT_SYSTEMD_PATH=""
ECAT_CONF_PATH=""
ETHERCAT_CONFIG=""


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


function get_list_from_file
{
    local empty_string="";
    declare -a entry=();
 
    while IFS= read -r line_data; do
	if [ "$line_data" ]; then
	    # Skip command #
	    [[ "$line_data" =~ ^#.*$ ]] && continue
	    entry[i]="${line_data}"
	    ((++i))
	fi
    done < $1
 
    echo ${entry[@]}
}


function get_macaddr
{
    local dev=${1};
    cat /sys/class/net/${dev}/address
}




function printf_tee
{
    local input=${1};
    local target=${2};
    # If target exists, it will be overwritten.
    ${SUDO_CMD} printf "%s" "${input}" | ${SUDO_CMD} tee "${target}";
};



function activate_ethercat_master_network
{
    ${SUDO_CMD} ip link set dev ${ETHERCAT_MASTER0} up
}


function setup_systemd
{
    mac_address=$(get_macaddr ${ETHERCAT_MASTER0});
 
    if [[ $(checkIfVar "${mac_address}") -eq "$EXIST" ]]; then
  
	printf ">>> Set up EtherCAT Master ... \n";
	printf "    %s : %s\n" "${ETHERCAT_MASTER0}" "${mac_address}"

	
	m4 -D_MASTER0_DEVICE="${mac_address}" -D_DEVICE_MODULES="${DEVICE_MODULES}" ${SC_TOP}/ethercat.conf.m4 > ${SC_TOP}/ethercat.conf_temp

	${SUDO_CMD} install -m 644 ${SC_TOP}/ethercat.conf_temp ${ETHERCAT_CONFIG}
	rm ${SC_TOP}/ethercat.conf_temp

	printf ">>> Setup the systemd in %s\n" "${SD_UNIT_PATH}"
	
	${SUDO_CMD} install -m 644 ${ECAT_SYSTEMD_PATH}/${ECAT_MASTER_SYSTEMD} ${SD_UNIT_PATH}/
        ${SUDO_CMD} systemctl daemon-reload;
        ${SUDO_CMD} systemctl enable ${ECAT_MASTER_SYSTEMD};

	printf ">>> One should run the following command later\n";
	printf "    systemctl start %s\n" "${ECAT_MASTER_SYSTEMD}"
	printf "\n"
  
    else
	printf "\n>>> We could find %s with the corresponding mac address %s\n" "${ETHERCAT_MASTER0}" "${mac_address}"
	printf "    Please check your system properly.\n";
	printf "    For example, one can define it via \n\n";
	printf "    echo \"ETHERCAT_MASTER0=eth0\" > ethercatmaster.local\n\n"
      	exit
    fi

}


function setup_dkms_systemd
{
    printf ">>> Setup the systemd %s in %s\n" "${ECAT_DKMS_SYSTEMD}" "${SD_UNIT_PATH}"

    ${SUDO_CMD} install -m 644 ${SC_TOP}/${ECAT_DKMS_SYSTEMD} ${SD_UNIT_PATH}/
    ${SUDO_CMD} systemctl daemon-reload;
    ${SUDO_CMD} systemctl enable ${ECAT_DKMS_SYSTEMD};
    ${SUDO_CMD} systemctl start ${ECAT_DKMS_SYSTEMD};
    printf "\n"
    
}

# arg1 : KMOD NAME
# arg2 : target_rootfs, if exists
function put_udev_rule
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

    printf ">>> Put the udev rule : %s in %s to be accessible via an user.\n" "$rule" "$target";
    printf "    "
    printf_tee "$rule" "$target";
    printf "\n";
    printf "\n>>> Check the $target with cat\n"
    printf "    "
    cat ${target}
    printf "\n"
}

# arg1 : device name
# arg2 : target_rootfs, if exists
function add_udev_rule_for_unmanaged
{
    local device=$1; shift;
    local target_rootfs=${1}; shift;
    local udev_rules_dir="${target_rootfs}/etc/udev/rules.d"
    local rule="";
    local target="";
    # We can check the its STATE by `nmcli dev status`
    # enp5s0      ethernet  unmanaged  --
    #
    # ACTION=="add", SUBSYSTEM=="net", KERNEL=="enp5s0", ENV{NM_UNMANAGED}="1"
    #
    rule="ACTION==\"add\", SUBSYSTEM==\"net\", KERNEL==\"${device}\", ENV{NM_UNMANAGED}=\"1\"";
    target="${udev_rules_dir}/00-unmanaged-device-by-nm.rules";

    printf ">>> Put the udev rule : %s in %s to be accessible via an user.\n" "$rule" "$target";
    printf "    "
    printf_tee "$rule" "$target";
    printf "\n";
    printf "\n>>> Check the $target with cat\n"
    printf "    "
    cat ${target}
    printf "\n"
}

 
function trigger_udev_rule
{

    if [ -f /bin/udevadm ]; then
	printf "\n>>> Reload udev rules, and trigger it\n"
	${SUDO_CMD} /bin/udevadm control --reload-rules
	${SUDO_CMD} /bin/udevadm trigger
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



options=":t:"


while getopts "${options}" opt; do
    case "${opt}" in
	t)
	    ETHERLAB_TARGET_PATH=${OPTARG} ;
	    ;;
	*)
	    usage
	    ;;
    esac
done
shift $((OPTIND-1))


ECAT_SYSTEMD_PATH=${ETHERLAB_TARGET_PATH}/lib/systemd/system
ECAT_CONF_PATH=${ETHERLAB_TARGET_PATH}/etc
ETHERCAT_CONFIG=${ECAT_CONF_PATH}/${ECAT_MASTER_CONF}

echo ">>> ---------------------------------------"
echo "ECAT_SYSTEMD_PATH : ${ECAT_SYSTEMD_PATH}"
echo "ECAT_CONF_PATH    : ${ECAT_CONF_PATH}"
echo "ETHERCAT_CONFIG   : ${ETHERCAT_CONFIG}"


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

## Activate the selected Ethernet Port for EtherCAT connection
activate_ethercat_master_network


# Setup Systemd for the DKMS autoinstall
# dkms.sevice will be started before ethercat.service be started.
setup_dkms_systemd


## Setup Systemd for the etercat.service
## We can put all configuration files and scrpits in ${ETHERLAB_TARGET_PATH}
## However, we cannot put ${ECAT_MASTER_SYSTEMD} in any customzied path
## Therefore, we have to consider carefully which system needs the ETERLAB master.
## 
setup_systemd


put_udev_rule "${ECAT_KMOD_NAME}"
# Disable unmamaged the device
# With RT, the device is NOT the network device anymore,
# So, we don't need it.
#add_udev_rule_for_unmanaged "${ETHERCAT_MASTER0}"

trigger_udev_rule


${SUDO_CMD} ln -sf ${ETHERLAB_TARGET_PATH}/bin/ethercat  /usr/bin/ethercat
printf "    "
printf_tee "${ETHERLAB_TARGET_PATH}/lib" "/etc/ld.so.conf.d/e3_ethercat.conf";
${SUDO_CMD} ldconfig 
printf "\n";


printf ">>>\n";
printf "It is mandatory to reboot your system once\n";
printf ">>>\n";

