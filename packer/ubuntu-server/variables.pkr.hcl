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

<<<<<<< HEAD
=======

>>>>>>> bd5052a (Updated variables.pkr.hcl for improved parameterization with aws region and instance)
variable "aws_region" {
  description = "AWS region to build the AMI"
  type        = string
  default     = "us-east-1"

}

<<<<<<< HEAD
=======

>>>>>>> bd5052a (Updated variables.pkr.hcl for improved parameterization with aws region and instance)
variable "aws_instance_type" {
  description = "AWS instance type for the build"
  type        = string
  default     = "t3.medium"

}