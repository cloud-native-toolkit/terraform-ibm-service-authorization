
#####################################################
# IAM authorization policy
# Copyright 2021 IBM
#####################################################

locals {
  source_resource_instance_id = var.source_instance ? var.source_resource_instance_id : null
  target_resource_instance_id = var.target_instance ? var.target_resource_instance_id : null
}

resource ibm_iam_authorization_policy policy {
  count = var.provision ? 1 : 0

  source_service_name         = var.source_service_name
  target_service_name         = var.target_service_name
  roles                       = var.roles
  source_resource_instance_id = local.source_resource_instance_id
  target_resource_instance_id = local.target_resource_instance_id
  source_resource_group_id    = var.source_resource_group_id
  target_resource_group_id    = var.target_resource_group_id
  source_resource_type        = var.source_resource_type
  target_resource_type        = var.target_resource_type
  source_service_account      = var.source_service_account
}
