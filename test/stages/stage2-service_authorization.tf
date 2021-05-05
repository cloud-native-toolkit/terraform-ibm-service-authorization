module "service_authorization" {
  source = "./module"

  source_service_name = "cloud-object-storage"
  target_service_name = "kms"
  roles = ["Reader"]
}
