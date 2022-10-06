module "service_authorization3" {
  source = "./module"

  source_service_name = "is"
  source_resource_type = "vpn-server"
  target_service_name = "secrets-manager"
  roles = ["SecretsReader"]

  ibmcloud_api_key = var.ibmcloud_api_key
}
