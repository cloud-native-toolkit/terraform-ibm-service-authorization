#####################################################
# IAM authorization policy
# Copyright 2020 IBM
#####################################################

output "iam_authorization_policy_id" {
  description = "The ID of the authorization policy ID"
  value       = ibm_iam_authorization_policy.policy.id
}
