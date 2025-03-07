variable "dibbs_service" {
  # dibbs-ecr-viewer
  # dibbs-query-connector
  description = "The name of the service to be built"
  type        = string
}

variable "dibbs_version" {
  # needs to be a valid tagged branch with built docker containers
  # main
  # v2.0.0-beta
  description = "The version of the service to be built"
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