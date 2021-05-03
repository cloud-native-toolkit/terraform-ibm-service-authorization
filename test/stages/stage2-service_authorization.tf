module "service_authorization" {
  source = "./module"

  source_service_name = "is"
  source_resource_type = "flow-log-collector"
  target_service_name = "cloud-object-storage"
  roles = ["Writer"]
}
