#!/bin/bash

# create dnsname enabled podman network
# podman network create 3trains
# { "capabilities": { "aliases": true }, "domainName": "dns.podman", "type": "dnsname" }
podman network reload --all 2>&1 >/dev/null
while read node ; do
    echo -n "Starting container ${node}.... "
    podman run --name=${node} --network 3trains --systemd=true  --workdir /work -v $(pwd):/work:rw  -dit localhost/ubi8/ubi-ansible-3trains-demo:latest /sbin/init
done < <( ansible-inventory -i inventory/demo --list | jq -r "._meta.hostvars | keys[]")
podman network reload --all 2>&1 >/dev/null
ANSIBLE_CONFIG=podman/ansible-podman.cfg ansible-playbook -e @rhn-creds.yml -i inventory/demo playbooks/demo.yml "$@"
