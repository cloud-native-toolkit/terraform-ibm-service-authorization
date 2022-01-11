#!/usr/bin/env bash

set -e


ibmcloud api cloud.ibm.com
ibmcloud login -q --no-region
ibmcloud target -r $REGION

ibmcloud iam authorization-policies --output JSON | jq '.[] | select(.resources[].attributes[].value == "cloud-object-storage") | select(.subjects[].attributes[].value == "flow-log-collector")'
AUTHORIZATION_COUNT=$(ibmcloud iam authorization-policies --output JSON | jq '.[] | select(.resources[].attributes[].value == "cloud-object-storage") | select(.subjects[].attributes[].value == "flow-log-collector") | .id' | wc -l)
if [[ "${AUTHORIZATION_COUNT}" -eq 0 ]]; then
  echo "Unable to find flow-log-collector authorization"
  exit 1
fi
