#!/bin/bash

environments=("dev test prod")
if [[ " ${environments[*]} " =~ " $1 " ]]; then
    echo "Running plan against $1 environment"
else
    echo "Invalid environment '$1' passed"
    echo "Must be one of: [${environments[*]}]"
    exit 1
fi

source ./scripts/switchenv.sh $1
terraform plan -var-file="./variables/$1.tfvars"
