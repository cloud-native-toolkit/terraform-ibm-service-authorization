#!/usr/bin/env bash

BIN_DIR=$(cat .bin_dir)

export PATH="${BIN_DIR}:${PATH}"

set -e

REGION=$(cat terraform.tfvars | grep -E "^region=" | sed -E 's/region="(.*)"/\1/g')

if [[ -z "${IBMCLOUD_API_KEY}" ]] || [[ -z "${REGION}" ]]; then
  echo "IBMCLOUD_API_KEY and REGION are required" >&2
  exit 1
fi

ibmcloud login -r "${REGION}" || exit 1

ibmcloud iam authorization-policies --output JSON | jq '.[] | select(.resources[].attributes[].value == "cloud-object-storage") | select(.subjects[].attributes[].value == "flow-log-collector")'
AUTHORIZATION_COUNT=$(ibmcloud iam authorization-policies --output JSON | jq '.[] | select(.resources[].attributes[].value == "cloud-object-storage") | select(.subjects[].attributes[].value == "flow-log-collector") | .id' | wc -l)
if [[ "${AUTHORIZATION_COUNT}" -eq 0 ]]; then
  echo "Unable to find flow-log-collector authorization"
  exit 1
fi
