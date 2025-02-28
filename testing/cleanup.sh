#!/usr/bin/bash

lxc project switch timenl


for vm in $(lxc ls -f csv -c n)
do
    lxc delete --force $vm
done

for image in $(lxc image list -c f -f csv)
do
    echo lxc image delete $image

done

sleep 5

for net in $(lxc network list -f csv | cut -d, -f1 | grep timenl-)
do
    lxc network delete $net
done

# lxc project delete timenl