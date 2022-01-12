#!/bin/bash

PATH=$BIN_DIR:$PATH
JQ=$(command -v jq | command -v ./bin/jq)

IAM_TOKEN=$(curl -s -X POST "https://iam.cloud.ibm.com/identity/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey=${IBMCLOUD_API_KEY}" | ${JQ} -r '.access_token')

ACCOUNT_ID=$(curl -s -X GET 'https://iam.cloud.ibm.com/v1/apikeys/details' \
  -H "Authorization: Bearer $IAM_TOKEN" -H "IAM-Apikey: ${IBMCLOUD_API_KEY}" \
  -H 'Content-Type: application/json' | ${JQ} -r '.account_id')

# Assemble the json payload
PAYLOAD="{\"type\":\"authorization\",\"subjects\":[{\"attributes\":[{\"name\":\"accountId\",\"value\":\"$ACCOUNT_ID\"}"

if [ ! -z "$SOURCE_SERVICE_NAME" ]; then
      PAYLOAD="$PAYLOAD,{\"name\":\"serviceName\",\"value\":\"$SOURCE_SERVICE_NAME\"}"
fi

if [ ! -z "$SOURCE_RESOURCE_INSTANCE_ID" ]
then
      PAYLOAD="$PAYLOAD,{\"name\":\"serviceInstance\",\"value\":\"$SOURCE_RESOURCE_INSTANCE_ID\"}"
fi

if [ ! -z "$SOURCE_RESOURCE_GROUP_ID" ]
then
      PAYLOAD="$PAYLOAD,{\"name\":\"resourceGroupId\",\"value\":\"$SOURCE_RESOURCE_GROUP_ID\"}"
fi

if [ ! -z "$SOURCE_SERVICE_ACCOUNT" ]
then
      PAYLOAD="$PAYLOAD,{\"name\":\"accountId\",\"value\":\"$SOURCE_SERVICE_ACCOUNT\"}"
fi

if [ ! -z "$SOURCE_RESOURCE_TYPE" ]
then
      PAYLOAD="$PAYLOAD,{\"name\":\"resourceType\",\"value\":\"$SOURCE_RESOURCE_TYPE\"}"
fi

COMPLETE_ROLES=""
for role in $(echo "$ROLES" | jq -r '.[]'); do
  if [[ -n "$COMPLETE_ROLES" ]] ; then
    COMPLETE_ROLES="$COMPLETE_ROLES,"
  fi
  COMPLETE_ROLES="$COMPLETE_ROLES{\"role_id\":\"crn:v1:bluemix:public:iam::::serviceRole:${role}\"}"
done


ATTRIBUTES=""

if [ ! -z "$TARGET_SERVICE_ACCOUNT" ]; then
      ATTRIBUTES="$ATTRIBUTES{\"name\":\"accountId\",\"value\":\"$TARGET_SERVICE_ACCOUNT\"}"
else 
      ATTRIBUTES="$ATTRIBUTES{\"name\":\"accountId\",\"value\":\"$ACCOUNT_ID\"}"
fi

if [ ! -z "$TARGET_SERVICE_NAME" ]; then
      ATTRIBUTES="$ATTRIBUTES,{\"name\":\"serviceName\",\"value\":\"$TARGET_SERVICE_NAME\"}"
fi

if [ ! -z "$TARGET_RESOURCE_INSTANCE_ID" ]; then
      ATTRIBUTES="$ATTRIBUTES,{\"name\":\"serviceInstance\",\"value\":\"$TARGET_RESOURCE_INSTANCE_ID\"}"
fi

if [ ! -z "$TARGET_RESOURCE_GROUP_ID" ]; then
      ATTRIBUTES="$ATTRIBUTES,{\"name\":\"resourceGroupId\",\"value\":\"$TARGET_RESOURCE_GROUP_ID\"}"
fi

if [ ! -z "$TARGET_RESOURCE_TYPE" ]; then
      ATTRIBUTES="$ATTRIBUTES,{\"name\":\"resourceType\",\"value\":\"$TARGET_RESOURCE_TYPE\"}"
fi

PAYLOAD="$PAYLOAD]}],\"roles\":[$COMPLETE_ROLES], \"resources\":[{\"attributes\":[$ATTRIBUTES]}]}"
#echo "PAYLOAD: $PAYLOAD"

# Submit request to IAM policy service
RESULT=$(curl -s --request POST   --url https://iam.cloud.ibm.com/v1/policies  \
  --header "Authorization: Bearer $IAM_TOKEN" \
  --header 'Content-Type: application/json' \
  --data "$PAYLOAD")


STATE=$( echo $RESULT | ${JQ} -r '.state')

#if valid json and state is active, it worked
if [ "$STATE" = "active" ]; then
  echo "Successfully created service authorization"

#otherwise check for "policy_conflict_error".  if found, ignore the error b/c it just means a duplicate service authorization
elif echo $RESULT | grep -q "policy_conflict_error"; then
  echo "Service authorization already exists"

#otherwise, surface the error
else 
  echo $RESULT
  exit 1
fi

