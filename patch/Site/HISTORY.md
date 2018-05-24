# use_prefix_for_ethercat_conf_path.p0.patch

ETHERCAT_CONFIG is harded-code in ethercatctl, so we cannot use the customized path.
This patch allows us to use the installed etherlab master configuration in a local or E3 path instead of the global path. 

* created by Jeong Han Lee, han.lee@esss.se
* Thursday, May 24 11:51:52 CEST 2018
