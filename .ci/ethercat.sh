#!/bin/bash


git clone https://github.com/icshwi/etherlabmaster
cd etherlabmaster

make init
make patch
make build
make install

sudo tee /etc/ld.so.conf.d/ethercat.conf >/dev/null <<EOF
/opt/etherlab/lib 
EOF

echo "Reading /etc/ld.so.conf.d/ethercat.conf"
cat /etc/ld.so.conf.d/ethercat.conf

echo "Updating ldconfig..."
sudo /sbin/ldconfig

#exit $?
