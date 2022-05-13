#!/bin/bash

export PATH="${BIN_DIR}:${PATH}"

IAM_TOKEN=$(curl -s -X POST "https://iam.cloud.ibm.com/identity/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey=${IBMCLOUD_API_KEY}" | jq -r '.access_token')

ACCOUNT_ID=$(curl -s -X GET 'https://iam.cloud.ibm.com/v1/apikeys/details' \
  -H "Authorization: Bearer $IAM_TOKEN" -H "IAM-Apikey: ${IBMCLOUD_API_KEY}" \
  -H 'Content-Type: application/json' | jq -r '.account_id')

if [[ -z "${ACCOUNT_ID}" ]]; then
  echo "ACCOUNT_ID could not be retrieve" >&2
  exit 1
fi

# Assemble the json payload

SUBJECT_ATTRIBUTES=$(jq -n --arg VALUE "${ACCOUNT_ID}" '[{"name": "accountId", "value": $VALUE}]')
SOURCE=""

if [[ -n "${SOURCE_SERVICE_ACCOUNT}" ]]; then
  SUBJECT_ATTRIBUTES=$(echo "${SUBJECT_ATTRIBUTES}" | jq --arg VALUE "${SOURCE_SERVICE_ACCOUNT}" '. += [{"name": "accountId", "value": $VALUE}]')
  SOURCE="${SOURCE}/${SOURCE_SERVICE_ACCOUNT}"
fi

if [[ -n "${SOURCE_RESOURCE_TYPE}" ]]; then
  SUBJECT_ATTRIBUTES=$(echo "${SUBJECT_ATTRIBUTES}" | jq --arg VALUE "${SOURCE_RESOURCE_TYPE}" '. += [{"name": "resourceType", "value": $VALUE}]')
  SOURCE="${SOURCE}/${SOURCE_RESOURCE_TYPE}"
fi

if [[ -n "${SOURCE_RESOURCE_GROUP_ID}" ]]; then
  SUBJECT_ATTRIBUTES=$(echo "${SUBJECT_ATTRIBUTES}" | jq --arg VALUE "${SOURCE_RESOURCE_GROUP_ID}" '. += [{"name": "resourceGroupId", "value": $VALUE}]')
  SOURCE="${SOURCE}/${SOURCE_RESOURCE_GROUP_ID}"
fi

if [[ -n "${SOURCE_SERVICE_NAME}" ]]; then
  SUBJECT_ATTRIBUTES=$(echo "${SUBJECT_ATTRIBUTES}" | jq --arg VALUE "${SOURCE_SERVICE_NAME}" '. += [{"name": "serviceName", "value": $VALUE}]')
  SOURCE="${SOURCE}/${SOURCE_SERVICE_NAME}"
fi

if [[ -n "${SOURCE_RESOURCE_INSTANCE_ID}" ]]; then
  SUBJECT_ATTRIBUTES=$(echo "${SUBJECT_ATTRIBUTES}" | jq --arg VALUE "${SOURCE_RESOURCE_INSTANCE_ID}" '. += [{"name": "serviceInstance", "value": $VALUE}]')
  SOURCE="${SOURCE}/${SOURCE_RESOURCE_INSTANCE_ID}"
fi


COMPLETE_ROLES="[]"
for role in $(echo "$ROLES" | jq -r '.[]'); do
  COMPLETE_ROLES=$(echo "${COMPLETE_ROLES}" | jq --arg ROLE "crn:v1:bluemix:public:iam::::serviceRole:${role}" '. += [{"role_id": $ROLE}]')
done


RESOURCE_ATTRIBUTES="[]"
TARGET=""

if [[ -n "${TARGET_SERVICE_ACCOUNT}" ]]; then
  RESOURCE_ATTRIBUTES=$(echo "${RESOURCE_ATTRIBUTES}" | jq --arg VALUE "${TARGET_SERVICE_ACCOUNT}" '. += [{"name": "accountId", "value": $VALUE}]')
  TARGET="${TARGET}/${TARGET_SERVICE_ACCOUNT}"
else
  RESOURCE_ATTRIBUTES=$(echo "${RESOURCE_ATTRIBUTES}" | jq --arg VALUE "${ACCOUNT_ID}" '. += [{"name": "accountId", "value": $VALUE}]')
  TARGET="${TARGET}/${ACCOUNT_ID}"
fi

if [[ -n "${TARGET_RESOURCE_TYPE}" ]]; then
  RESOURCE_ATTRIBUTES=$(echo "${RESOURCE_ATTRIBUTES}" | jq --arg VALUE "${TARGET_RESOURCE_TYPE}" '. += [{"name": "resourceType", "value": $VALUE}]')
  TARGET="${TARGET}/${TARGET_RESOURCE_TYPE}"
fi

if [[ -n "${TARGET_RESOURCE_GROUP_ID}" ]]; then
  RESOURCE_ATTRIBUTES=$(echo "${RESOURCE_ATTRIBUTES}" | jq --arg VALUE "${TARGET_RESOURCE_GROUP_ID}" '. += [{"name": "resourceGroupId", "value": $VALUE}]')
  TARGET="${TARGET}/${TARGET_RESOURCE_GROUP_ID}"
fi

if [[ -n "${TARGET_SERVICE_NAME}" ]]; then
  RESOURCE_ATTRIBUTES=$(echo "${RESOURCE_ATTRIBUTES}" | jq --arg VALUE "${TARGET_SERVICE_NAME}" '. += [{"name": "serviceName", "value": $VALUE}]')
  TARGET="${TARGET}/${TARGET_SERVICE_NAME}"
fi

if [[ -n "${TARGET_RESOURCE_INSTANCE_ID}" ]]; then
  RESOURCE_ATTRIBUTES=$(echo "${RESOURCE_ATTRIBUTES}" | jq --arg VALUE "${TARGET_RESOURCE_INSTANCE_ID}" '. += [{"name": "serviceInstance", "value": $VALUE}]')
  TARGET="${TARGET}/${TARGET_RESOURCE_INSTANCE_ID}"
fi

DESCRIPTION="Service auth: source=${SOURCE}, target=${TARGET} owner=[${UUID}]"

PAYLOAD=$(jq -n \
  --argjson SUBJECTS "${SUBJECT_ATTRIBUTES}" \
  --argjson RESOURCES "${RESOURCE_ATTRIBUTES}" \
  --argjson ROLES "${COMPLETE_ROLES}" \
  --arg DESCRIPTION "${DESCRIPTION}" \
  '{"type": "authorization", "description": $DESCRIPTION, "subjects": [{"attributes": $SUBJECTS}], "roles": $ROLES, "resources": [{"attributes": $RESOURCES}]}')

echo "Payload: ${PAYLOAD}"

# Submit request to IAM policy service
POLICY_RESULT=$(curl -s -i --request POST --url https://iam.cloud.ibm.com/v1/policies  \
  --header "Authorization: Bearer $IAM_TOKEN" \
  --header 'Content-Type: application/json' \
  --data "$PAYLOAD")

RESULT=$(echo "${POLICY_RESULT}" | tail -1)

echo "Policy result: ${POLICY_RESULT}"


STATE=$(echo "${RESULT}" | jq -r '.state')

#if valid json and state is active, it worked
if [[ "${STATE}" == "active" ]]; then
  echo "Successfully created service authorization"

#otherwise check for "policy_conflict_error".  if found, ignore the error b/c it just means a duplicate service authorization
elif echo "${RESULT}" | grep -q "policy_conflict_error"; then
  echo "Service authorization already exists"

#otherwise, surface the error
else 
  echo "Result: ${POLICY_RESULT}"
  exit 1
fi
