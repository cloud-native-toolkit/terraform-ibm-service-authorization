#!/bin/bash

export PATH="${BIN_DIR}:${PATH}"

IAM_TOKEN=$(curl -s -X POST "https://iam.cloud.ibm.com/identity/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey=${IBMCLOUD_API_KEY}" | jq -r '.access_token')

ACCOUNT_ID=$(curl -s -X GET 'https://iam.cloud.ibm.com/v1/apikeys/details' \
  -H "Authorization: Bearer $IAM_TOKEN" -H "IAM-Apikey: ${IBMCLOUD_API_KEY}" \
  -H 'Content-Type: application/json' | jq -r '.account_id')

if [[ -z "${ACCOUNT_ID}" ]]; then
  echo "ACCOUNT_ID could not be retrieve"
  exit 0
fi

# Assemble the json payload

SOURCE=""

if [[ -n "${SOURCE_SERVICE_ACCOUNT}" ]]; then
  SOURCE="${SOURCE}/${SOURCE_SERVICE_ACCOUNT}"
fi

if [[ -n "${SOURCE_RESOURCE_TYPE}" ]]; then
  SOURCE="${SOURCE}/${SOURCE_RESOURCE_TYPE}"
fi

if [[ -n "${SOURCE_RESOURCE_GROUP_ID}" ]]; then
  SOURCE="${SOURCE}/${SOURCE_RESOURCE_GROUP_ID}"
fi

if [[ -n "${SOURCE_SERVICE_NAME}" ]]; then
  SOURCE="${SOURCE}/${SOURCE_SERVICE_NAME}"
fi

if [[ -n "${SOURCE_RESOURCE_INSTANCE_ID}" ]]; then
  SOURCE="${SOURCE}/${SOURCE_RESOURCE_INSTANCE_ID}"
fi

TARGET=""

if [[ -n "${TARGET_SERVICE_ACCOUNT}" ]]; then
  TARGET="${TARGET}/${TARGET_SERVICE_ACCOUNT}"
else
  TARGET="${TARGET}/${ACCOUNT_ID}"
fi

if [[ -n "${TARGET_RESOURCE_TYPE}" ]]; then
  TARGET="${TARGET}/${TARGET_RESOURCE_TYPE}"
fi

if [[ -n "${TARGET_RESOURCE_GROUP_ID}" ]]; then
  TARGET="${TARGET}/${TARGET_RESOURCE_GROUP_ID}"
fi

if [[ -n "${TARGET_SERVICE_NAME}" ]]; then
  TARGET="${TARGET}/${TARGET_SERVICE_NAME}"
fi

if [[ -n "${TARGET_RESOURCE_INSTANCE_ID}" ]]; then
  TARGET="${TARGET}/${TARGET_RESOURCE_INSTANCE_ID}"
fi

DESCRIPTION="Service auth: source=${SOURCE}, target=${TARGET} owner=[${UUID}]"

POLICY_ID=$(curl -s -X GET "https://iam.cloud.ibm.com/v1/policies?account_id=${ACCOUNT_ID}&type=authorization&state=active" \
  -H "Authorization: Bearer $IAM_TOKEN" \
  -H 'Content-Type: application/json' | \
  jq -c --arg DESCRIPTION "${DESCRIPTION}" '.policies[] | select(.description != null) | select(.description == $DESCRIPTION) | .id')

if [[ -z "${POLICY_ID}" ]]; then
  echo "No policy found matching description: ${DESCRIPTION}"
  exit 0
fi

echo "Deleting policy with id: ${POLICY_ID}"

RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "https://iam.cloud.ibm.com/v1/policies/${POLICY_ID}" \
  -H "Authorization: Bearer $IAM_TOKEN" \
  -H 'Content-Type: application/json')

#if valid json and state is active, it worked
if [[ "${RESPONSE}" -eq 204 ]]; then
  echo "Successfully deleted service authorization"

#otherwise check for "policy_conflict_error".  if found, ignore the error b/c it just means a duplicate service authorization
else
  echo "Deelte result: ${RESPONSE}"
  exit 0
fi
