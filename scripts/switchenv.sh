#!/bin/bash

environments=("dev test prod")
if [[ " ${environments[*]} " =~ " $1 " ]]; then
    echo "Switching to $1 environment"
else
    echo "Invalid environment '$1' passed"
    echo "Must be one of: [${environments[*]}]"
    exit 1
fi

export KUBE_CONFIG_PATH=~/.kube/config
terraform init -reconfigure -backend-config=./backends/$1.tfbackend
