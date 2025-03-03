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
