#####################################################
# IAM authorization policy
# Copyright 2021 IBM
#####################################################

output "iam_authorization_policy_id" {
  description = "The ID of the authorization policy ID"
  value       = var.provision ? ibm_iam_authorization_policy.policy[0].id : ""
}
