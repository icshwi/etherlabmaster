Troubleshooting
===

## make build error

* need to install proper package, and reboot the system once in order to match the running kernel version and installed kernel source all together. 

```
configure: error: Failed to find Linux sources. Use --with-linux-dir!
make[1]: *** [autoconf] Error 1
```

## cannot start systemd service

### Case 1: Secure Boot

* Disable the Secure Boot in the BIOS configuration, once one has the following error: `ERROR: could not insert 'ec_master': Required key not available`

```
$ systemctl start ethercat.service
Job for ethercat.service failed because the control process exited with error code. See "systemctl status ethercat.service" and "journalctl -xe" for details. 

$ journalctl -xe


-- Subject: Unit ethercat.service has begun start-up
-- Defined-By: systemd
-- Support: http://lists.freedesktop.org/mailman/listinfo/systemd-devel
-- 
-- Unit ethercat.service has begun starting up.
Jan 07 07:23:04 mcag-epics9 ethercatctl[20684]: modprobe: ERROR: could not insert 'ec_master': Required key not available
Jan 07 07:23:04 mcag-epics9 systemd[1]: ethercat.service: main process exited, code=exited, status=1/FAILURE
Jan 07 07:23:04 mcag-epics9 systemd[1]: Failed to start EtherCAT Master Kernel Modules.
-- Subject: Unit ethercat.service has failed
-- Defined-By: systemd
-- Support: http://lists.freedesktop.org/mailman/listinfo/systemd-devel
-- 
-- Unit ethercat.service has failed.
-- 
-- The result is failed. 
```

### Case 2: dkms.service failed

```
Oct 23 14:41:49 cslab-ccpu-bi-3.cslab.esss.lu.se systemd[1]: Dependency failed for EtherCAT Master Kernel Modules.
-- Subject: Unit ethercat.service has failed
-- Defined-By: systemd
-- Support: http://lists.freedesktop.org/mailman/listinfo/systemd-devel
-- 
-- Unit ethercat.service has failed.
-- 
-- The result is dependency.
Oct 23 14:41:49 cslab-ccpu-bi-3.cslab.esss.lu.se systemd[1]: Job ethercat.service/start failed with result 'dependency'.
Oct 23 14:41:49 cslab-ccpu-bi-3.cslab.esss.lu.se systemd[1]: Unit dkms.service entered failed state.
Oct 23 14:41:49 cslab-ccpu-bi-3.cslab.esss.lu.se systemd[1]: dkms.service failed.
Oct 23 14:41:49 cslab-ccpu-bi-3.cslab.esss.lu.se polkitd[1029]: Unregistered Authentication Agent for unix-process:27557:345677 (system bus name :1.232, object path /org/freedesktop/PolicyKit1/AuthenticationAgent, locale en_US.UTF-8) (disconnected from bus)
Oct 23 14:41:49 cslab-ccpu-bi-3.cslab.esss.lu.se sudo[27555]: pam_unix(sudo:session): session closed for user root
Oct 23 14:41:52 cslab-ccpu-bi-3.cslab.esss.lu.se dhclient[27608]: DHCPDISCOVER on enp18s0f1 to 255.255.255.255 port 67 interval 9 (xid=0x39b4c22d)
```

One should find the reason why the dkms service failed. Once fix it, please start `ethercat` via `systemctl start ethercat`


##  One can see nothing via `ethercat slave` with `generic driver`. One should the up the ethercat master via

```
sudo ip link set dev ${ETHERCAT_MASTER0} up
```
