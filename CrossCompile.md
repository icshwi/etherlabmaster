```
etherlabmaster-code (master)$ unset LD_LIBRARY_PATH
etherlabmaster-code (master)$ source /opt/ifc14xx/2.6-4.14/environment-setup-ppc64e6500-fsl-linux
etherlabmaster-code (master)$ ./configure --enable-generic --disable-8139too --disable-e100 --disable-e1000 --disable-e1000e --disable-igb --disable-r8169 --disable-ccat --enable-static=yes --enable-shared=yes --enable-eoe=no --enable-cycles=yes --enable-hrtimer=no --enable-regalias=no --enable-tool=yes --enable-userlib=yes --enable-sii-assign=yes --enable-rt-syslog=yes --prefix=/opt/etherlab --host=${ARCH} --with-libtool-sysroot=${SDKTARGETSYSROOT}
etherlabmaster-code (master)$ make

etherlabmaster-code (master)$ readelf -h tool/ethercat
ELF Header:
  Magic:   7f 45 4c 46 02 02 01 00 00 00 00 00 00 00 00 00 
  Class:                             ELF64
  Data:                              2's complement, big endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              DYN (Shared object file)
  Machine:                           PowerPC64
  Version:                           0x1
  Entry point address:               0x8d8e0
  Start of program headers:          64 (bytes into file)
  Start of section headers:          9549680 (bytes into file)
  Flags:                             0x1, abiv1
  Size of this header:               64 (bytes)
  Size of program headers:           56 (bytes)
  Number of program headers:         8
  Size of section headers:           64 (bytes)
  Number of section headers:         39
  Section header string table index: 38
```

