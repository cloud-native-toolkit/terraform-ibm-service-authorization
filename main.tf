
#####################################################
# IAM authorization policy
# Copyright 2021 IBM
#####################################################

locals {
  source_resource_instance_id = var.source_instance ? var.source_resource_instance_id : null
  target_resource_instance_id = var.target_instance ? var.target_resource_instance_id : null
}

module "clis" {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}

resource null_resource create_authorization_policy {
  count = var.provision ? 1 : 0
  provisioner "local-exec" {
      command = "${path.module}/scripts/create-authorization-policy.sh"
      environment = {
        IBMCLOUD_API_KEY = var.ibmcloud_api_key
        SOURCE_SERVICE_NAME         = var.source_service_name
        TARGET_SERVICE_NAME         = var.target_service_name
        ROLES                       = jsonencode(var.roles)
        SOURCE_RESOURCE_INSTANCE_ID = local.source_resource_instance_id
        TARGET_RESOURCE_INSTANCE_ID = local.target_resource_instance_id
        SOURCE_RESOURCE_GROUP_ID    = var.source_resource_group_id
        TARGET_RESOURCE_GROUP_ID    = var.target_resource_group_id
        SOURCE_RESOURCE_TYPE        = var.source_resource_type
        TARGET_RESOURCE_TYPE        = var.target_resource_type
        SOURCE_SERVICE_ACCOUNT      = var.source_service_account
        BIN_DIR = module.clis.bin_dir
      }
  }
}
