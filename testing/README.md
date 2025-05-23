# Testing in VMs

This folder contains scripts to setup and tear-down the needed servers in LXD.

## Setup

To use these VMs you need to have LXD installed and your user added to the lxd group:

```bash
sudo snap install lxd
sudo adduser $USER lxd
newgrp lxd
sudo lxd init
# Select dir as storage pool
```

See also: https://canonical.com/lxd/install

## Running the VMs and apply Ansible

Starting all needed VMs:
```bash
bash start-local-vms.sh
```

Check that all VMs are running:
```bash
lxc project switch timenl
lxc ls
```

Updating the IP addresses: (TODO automate this step)
```bash
lxc ls -f json | jq -c '[.[] | {key: .name, value: [.state.network | to_entries | .[] | {name: .key, address: [.value.addresses.[].address] | map(select(test("^(fd0)")))[0]}] | map(select(.address != null)) | sort_by(.address)}] | from_entries'
```

And paste the output in `inventory.toml` in the vars.ips field.

Running the playbook(s):
```bash
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.yaml ../testing.playbook.yml ../playbook.yaml
```

You should now have a set of VMs configured for running like on the real mashines and networks.


## Debugging

If you want to inspect a machine you can use:

```bash
lxc shell e1
# or
lxc shell e2
# or
lxc shell monitor
# or
lxc shell grandmaster
```

You can also use wireshark to listen in on the three different networks.

## Cleaning up

Run `cleanup.sh` it will delete all the created networks, VMs and storage.
