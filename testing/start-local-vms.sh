#!/usr/bin/bash
set -e

cat testing-key.pub > /dev/null || ssh-keygen -t ed25519 -f testing-key -N ""

lxc project create timenl || echo "Project already exists"
lxc project switch timenl

lxc network create timenl-client ipv4.address=172.16.0.1/24 ipv4.nat=true ipv6.address=fd00::1/64 ipv6.nat=false ipv6.dhcp.stateful=false || echo "Network timenl-client already exists"
lxc network create timenl-time ipv4.address=172.16.1.1/24 ipv4.nat=true ipv6.address=fd01::1/64 ipv6.nat=true ipv6.dhcp.stateful=false || echo "Network timenl-time already exists"
lxc network create timenl-manage ipv4.address=172.16.2.1/24 ipv4.nat=true ipv6.address=fd02::1/64 ipv6.nat=true ipv6.dhcp.stateful=false || echo "Network timenl-manage already exists"

lxc profile device add default root disk pool=default path=/ || echo "Pool already set up"
lxc profile set default cloud-init.user-data="$(printf "#cloud-config\nssh_authorized_keys: ['$(cat testing-key.pub)']")"

NETWORK_INIT=$(cat << EOF
network:
  version: 2
  ethernets:
    any:
      match:
        name: enp*
      dhcp4: true
      dhcp6: true
EOF
)
lxc profile set default cloud-init.network-config="$NETWORK_INIT"

lxc init ubuntu:24.04 e1 --vm --ephemeral -n timenl-client
lxc network attach timenl-time e1
lxc network attach timenl-manage e1
lxc start e1

lxc init ubuntu:24.04 e2 --vm --ephemeral -n timenl-client
lxc network attach timenl-time e2
lxc network attach timenl-manage e2
lxc start e2

lxc launch ubuntu:24.04 grandmaster --vm --ephemeral -n timenl-time
lxc launch ubuntu:24.04 monitor --vm --ephemeral -n timenl-manage

for vm in e1 e2 grandmaster monitor
do
    lxc exec $vm -- cloud-init status --wait
done
