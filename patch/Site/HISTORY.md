# use_prefix_for_ethercat_conf_path.p0.patch

ETHERCAT_CONFIG is harded-code in ethercatctl, so we cannot use the customized path.
This patch allows us to use the installed etherlab master configuration in a local or E3 path instead of the global path. 

* created by Jeong Han Lee, han.lee@esss.se
* Thursday, May 24 11:51:52 CEST 2018


# after_dkms_service_patch.p0.patch

The dkms.service demon should be run before the ethercat.service will be started. 

```
etherlabmaster-code (master)$ hg diff script/ethercat.service.in > ../patch/Site/after_dkms_service_patch.p0.patch
```
