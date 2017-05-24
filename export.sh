#!/usr/bin/env bash
#===============================================================================
#   DESCRIPTION: import.sh
#        AUTHOR: Aleksandr Kukhar (kyxap), kyxap@kyxap.pro
#       COMPANY: Fasten.com
#  ORGANIZATION: Operations
#       CREATED: 04/24/17 23:36 +0000 UTC
#===============================================================================
#set -o pipefail
#set -eux

DATA=/data
LIST=${DATA}/.aws_services
STATE=${DATA}/terraform.tfstate
OUTPUT=${DATA}/.terraform

# 0. output dir
mkdir -p ${OUTPUT} || { echo "Directory error: ${OUTPUT}" >&2; exit 1; }

# 1. list
terraforming help \
  | grep terraforming \
  | grep -v help \
  | awk '{print $2}' \
  | tee ${LIST}

# 2. dump
AWS_REGIONS=(us-east-1 us-east-2 us-west-1 us-west-2 eu-central-1 eu-west-1)

for region in "${AWS_REGIONS[@]}"
do
  export AWS_REGION=${region}
  cat ${LIST} | while read service
  do
    # /terraform/service.tf
    terraforming ${service} | tee ${OUTPUT}/${service}.tf

    [[ -s ${STATE} ]] || { terraforming ${service} --tfstate > ${STATE}; continue; }

    # terraform.tfstate
    terraforming ${service} --tfstate --merge=${STATE} --overwrite
  done

done

