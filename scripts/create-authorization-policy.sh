#!/bin/bash

PATH=$BIN_DIR:$PATH

ibmcloud api cloud.ibm.com
echo "ibmcloud login --q --apikey ${IBMCLOUD_API_KEY} --no-region"
ibmcloud login --q --apikey ${IBMCLOUD_API_KEY} --no-region
ibmcloud target -r $REGION


COMMAND="ibmcloud iam authorization-policy-create $SOURCE_SERVICE_NAME $TARGET_SERVICE_NAME $(echo $ROLES | jq -r '.| join(",")')"

if [ ! -z "$SOURCE_RESOURCE_INSTANCE_ID" ]
then
      COMMAND="$COMMAND --source-service-instance-id $SOURCE_RESOURCE_INSTANCE_ID"
fi

if [ ! -z "$SOURCE_RESOURCE_INSTANCE_ID" ]
then
      COMMAND="$COMMAND --source-resource-group-id $SOURCE_RESOURCE_GROUP_ID"
fi

if [ ! -z "$SOURCE_RESOURCE_INSTANCE_ID" ]
then
      COMMAND="$COMMAND --source-service-account $SOURCE_SERVICE_ACCOUNT"
fi

if [ ! -z "$SOURCE_RESOURCE_INSTANCE_ID" ]
then
      COMMAND="$COMMAND --source-resource-type $SOURCE_RESOURCE_TYPE"
fi


if [ ! -z "$TARGET_RESOURCE_INSTANCE_ID" ]
then
      COMMAND="$COMMAND --target-service-instance-id $TARGET_RESOURCE_INSTANCE_ID"
fi

if [ ! -z "$TARGET_RESOURCE_INSTANCE_ID" ]
then
      COMMAND="$COMMAND --target-resource-group-id $TARGET_RESOURCE_GROUP_ID"
fi

if [ ! -z "$TARGET_RESOURCE_INSTANCE_ID" ]
then
      COMMAND="$COMMAND --target-service-account $TARGET_SERVICE_ACCOUNT"
fi

if [ ! -z "$TARGET_RESOURCE_INSTANCE_ID" ]
then
      COMMAND="$COMMAND --target-resource-type $TARGET_RESOURCE_TYPE"
fi

echo $COMMAND
RESULT="$(eval "$COMMAND  --output json" 2>&1 || true)"

# if valid json result, assume it is successful
if echo $RESULT | jq -e . >/dev/null 2>&1; then
  echo "Successfully created service authorization"

#otherwise check for "policy_conflict_error".  if found, ignore the error b/c it just means a duplicate service authorization
elif echo $RESULT | grep -q "policy_conflict_error"; then
  echo "Service authorization already exists"

#otherwise, surface the error
else 
  echo $RESULT
  exit 1
fi
