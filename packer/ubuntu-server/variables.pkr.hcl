# This file defines variables for the Packer template used to build the Ubuntu server for the dibbs services.
# 
# Variables:
# 
# - `dibbs_service` (string): The name of the service to be built. Acceptable values include:
#   - `dibbs-ecr-viewer`
#   - `dibbs-query-connector`
# 
# - `dibbs_version` (string): The version of the service to be built. This should be a valid tagged branch with built Docker containers. Example values include:
#   - `main`
#   - `v2.0.0-beta`

variable "dibbs_service" {
  description = "The name of the service to be built"
  type        = string
}

variable "dibbs_version" {
  description = "The version of the service to be built"
  type        = string
}

variable "gitsha" {
  description = "Git SHA of the current commit"
  type        = string
}

variable "aws_region" {
  description = "AWS region to build the AMI"
  type        = string
  default     = "us-east-1"

}

variable "aws_instance_type" {
  description = "AWS instance type for the build"
  type        = string
  default     = "t3.medium"
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = env("ARM_SUBSCRIPTION_ID") # Automatically pulls from env
}

variable "client_id" {
  description = "Azure Client ID"
  type        = string
  default     = env("ARM_CLIENT_ID")
}

variable "client_secret" {
  description = "Azure Client Secret"
  type        = string
  default     = env("ARM_CLIENT_SECRET")
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
  default     = env("ARM_TENANT_ID")
}

variable "ssh_password" {
  description = "SSH password for system configuration"
  type        = string
}

variable "build_type" {
  description = "Build type for the image"
  type        = string
  default     = "raw"
}
