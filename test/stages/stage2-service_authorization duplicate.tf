
# This is a duplicate of stage2-service_authorization.  
# This ensures that the module does not fail if the service auth already exists.

module "service_authorization2" {
  source = "./module"

  source_service_name = "cloud-object-storage"
  target_service_name = "kms"
  roles = ["Reader"]

  ibmcloud_api_key = var.ibmcloud_api_key
}
