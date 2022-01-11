module "service_authorization" {
  source = "./module"

  source_service_name = "cloud-object-storage"
  target_service_name = "kms"
  roles = ["Reader"]

  ibmcloud_api_key = var.ibmcloud_api_key
}
