
#####################################################
# IAM authorization policy
# Copyright 2021 IBM
#####################################################

locals {
  source_resource_instance_id = var.source_instance ? var.source_resource_instance_id : ""
  target_resource_instance_id = var.target_instance ? var.target_resource_instance_id : ""
}

module "clis" {
  source  = "cloud-native-toolkit/clis/util"
  version = "1.13.0"

  clis = ["jq"]
}

resource random_uuid tag {
}

resource null_resource create_authorization_policy {
  count = var.provision ? 1 : 0

  triggers = {
    IBMCLOUD_API_KEY            = var.ibmcloud_api_key
    SOURCE_SERVICE_NAME         = var.source_service_name
    TARGET_SERVICE_NAME         = var.target_service_name
    ROLES                       = jsonencode(var.roles)
    SOURCE_RESOURCE_INSTANCE_ID = local.source_resource_instance_id
    TARGET_RESOURCE_INSTANCE_ID = local.target_resource_instance_id
    SOURCE_RESOURCE_GROUP_ID    = var.source_resource_group_id != null ? var.source_resource_group_id : ""
    TARGET_RESOURCE_GROUP_ID    = var.target_resource_group_id != null ? var.target_resource_group_id : ""
    SOURCE_RESOURCE_TYPE        = var.source_resource_type != null ? var.source_resource_type : ""
    TARGET_RESOURCE_TYPE        = var.target_resource_type != null ? var.target_resource_type : ""
    SOURCE_SERVICE_ACCOUNT      = var.source_service_account != null ? var.source_service_account : ""
    UUID                        = random_uuid.tag.result
    BIN_DIR                     = module.clis.bin_dir
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/create-authorization-policy.sh"

    environment = {
      IBMCLOUD_API_KEY            = nonsensitive(self.triggers.IBMCLOUD_API_KEY)
      SOURCE_SERVICE_NAME         = self.triggers.SOURCE_SERVICE_NAME
      TARGET_SERVICE_NAME         = self.triggers.TARGET_SERVICE_NAME
      ROLES                       = self.triggers.ROLES
      SOURCE_RESOURCE_INSTANCE_ID = self.triggers.SOURCE_RESOURCE_INSTANCE_ID
      TARGET_RESOURCE_INSTANCE_ID = self.triggers.TARGET_RESOURCE_INSTANCE_ID
      SOURCE_RESOURCE_GROUP_ID    = self.triggers.SOURCE_RESOURCE_GROUP_ID
      TARGET_RESOURCE_GROUP_ID    = self.triggers.TARGET_RESOURCE_GROUP_ID
      SOURCE_RESOURCE_TYPE        = self.triggers.SOURCE_RESOURCE_TYPE
      TARGET_RESOURCE_TYPE        = self.triggers.TARGET_RESOURCE_TYPE
      SOURCE_SERVICE_ACCOUNT      = self.triggers.SOURCE_SERVICE_ACCOUNT
      UUID                        = self.triggers.UUID
      BIN_DIR                     = self.triggers.BIN_DIR
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${path.module}/scripts/delete-authorization-policy.sh"

    environment = {
      IBMCLOUD_API_KEY            = nonsensitive(self.triggers.IBMCLOUD_API_KEY)
      SOURCE_SERVICE_NAME         = self.triggers.SOURCE_SERVICE_NAME
      TARGET_SERVICE_NAME         = self.triggers.TARGET_SERVICE_NAME
      ROLES                       = self.triggers.ROLES
      SOURCE_RESOURCE_INSTANCE_ID = self.triggers.SOURCE_RESOURCE_INSTANCE_ID
      TARGET_RESOURCE_INSTANCE_ID = self.triggers.TARGET_RESOURCE_INSTANCE_ID
      SOURCE_RESOURCE_GROUP_ID    = self.triggers.SOURCE_RESOURCE_GROUP_ID
      TARGET_RESOURCE_GROUP_ID    = self.triggers.TARGET_RESOURCE_GROUP_ID
      SOURCE_RESOURCE_TYPE        = self.triggers.SOURCE_RESOURCE_TYPE
      TARGET_RESOURCE_TYPE        = self.triggers.TARGET_RESOURCE_TYPE
      SOURCE_SERVICE_ACCOUNT      = self.triggers.SOURCE_SERVICE_ACCOUNT
      UUID                        = self.triggers.UUID
      BIN_DIR                     = self.triggers.BIN_DIR
    }
  }
}
