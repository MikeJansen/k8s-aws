#!/bin/ash

ansible-playbook -i inventory "$@" up.yaml || ansible-playbook -i inventory -t cleanup up.yaml
