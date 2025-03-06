#!/usr/bin/bash

if [ $1 = '--list' ]; then
    lxc ls -f json | jq -c '{all: {hosts: [ .[] | .name ]}}'
    exit 0
fi

lxc ls -f json | jq -c '{ips: [.[] | {key: .name, value: [.state.network | to_entries | .[] | {name: .key, address: [.value.addresses.[].address] | map(select(test("^(fd0)")))[0]}] | map(select(.address != null)) | sort_by(.address)}] | from_entries}'
