# Site Specific EPICS Module Patch Files

## Changes
The changes were tested in local environemnt, and commits to the forked repository and do pull request to the epics community module repository.

* Check the original HASH, and your own master
* feb8856 : The original HASH
* master : Changed


## How to create a p0 patch file between commits


* Show what the difference between commits


* Create p0 patch

```
$git diff feb8856 master --no-prefix > ../patch/Site/what_ever_filename.p0.patch
```

