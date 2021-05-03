
#####################################################
# IAM authorization policy
# Copyright 2020 IBM
#####################################################

resource "ibm_iam_authorization_policy" "policy" {
  source_service_name         = var.source_service_name
  target_service_name         = var.target_service_name
  roles                       = var.roles
  source_resource_instance_id = (var.source_resource_instance_id != null ? var.source_resource_instance_id : null)
  target_resource_instance_id = (var.target_resource_instance_id != null ? var.target_resource_instance_id : null)
  source_resource_group_id    = (var.source_resource_group_id != null ? var.source_resource_group_id : null)
  target_resource_group_id    = (var.target_resource_group_id != null ? var.target_resource_group_id : null)
  source_resource_type        = (var.source_resource_type != null ? var.source_resource_type : null)
  target_resource_type        = (var.target_resource_type != null ? var.target_resource_type : null)
  source_service_account      = (var.source_service_account != null ? var.source_service_account : null)
}
