#####################################################
# IAM authorization policy
# Copyright 2021 IBM
#####################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud api key"
  sensitive   = true
}

variable "source_service_name" {
  description = "The name of the service that will be authorized to access the target service. This value is the name of the service as it appears in the service catalog."
  type        = string
}

variable "target_service_name" {
  description = "The name of the service to which the source service will be authorization to access. This value is the name of the service as it appears in the service catalog."
  type        = string
}

variable "roles" {
  type        = list(string)
  description = "A list of roles that should be granted on the target service (e.g. Reader, Writer)."
  default     = ["Reader"]
}

variable "source_resource_instance_id" {
  description = "The instance id of the source service. This value is required if the authorization will be scoped to a specific service instance. If not provided the authorization will be scoped to the resource group or the account."
  type        = string
  default     = ""
}

variable "target_resource_instance_id" {
  description = "The instance id of the target service. This value is required if the authorization will be scoped to a specific service instance. If not provided the authorization will be scoped to the resource group or the account."
  type        = string
  default     = ""
}

variable "source_resource_group_id" {
  description = "The id of the resource group that will be used to scope which source services will be authorized to access the target service. If not provided the authorization will be scoped to the entire account. This value is superseded by the source_resource_instance_id"
  type        = string
  default     = ""
}

variable "target_resource_group_id" {
  description = "The id of the resource group that will be used to scope which services the source services will be authorized to access. If not provided the authorization will be scoped to the entire account. This value is superseded by the target_resource_instance_id"
  type        = string
  default     = ""
}

variable "source_resource_type" {
  description = "The resource type of the source service. This value is used to define sub-types of services in the service catalog (e.g. flow-log-collector)."
  type        = string
  default     = ""
}

variable "target_resource_type" {
  description = "The resource type of the target service. This value is used to define sub-types of services in the service catalog (e.g. flow-log-collector)."
  type        = string
  default     = ""
}

variable "source_service_account" {
  description = "GUID of the account where the source service is provisioned. This is required to authorize service access across accounts."
  type        = string
  default     = ""
}

variable "provision" {
  description = "Flag indicating that the service authorization should be created"
  type        = bool
  default     = true
}

variable "source_instance" {
  description = "Flag indicating that the source instance id should be mapped"
  type        = bool
  default     = false
}

variable "target_instance" {
  description = "Flag indicating that the target instance id should be mapped"
  type        = bool
  default     = false
}
