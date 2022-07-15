variable "name" {}

variable "image_repository" {}
variable "image_tag" {}
variable "image_pull_secrets" {
  type        = list(string)
  description = "List of secrets containing image pull credentials"
}

variable "k8s_namespace" {}

variable "k8s_labels" {
  type = map(string)
}

variable "k8s_node_selector" {
  type    = map(string)
  default = {}
}

variable "k8s_storage_class_name" {
  type = string
}

variable "kafka_bootstrap_servers" {
  type = string
}

variable "kafka_consumer_group_id" {
  type = string
}

variable "resource_memory" {
  default = "1024Mi"
}

variable "q_license_path" {
  description = "Path to the Q license"
}

variable "q_license_hostname" {
  description = "Hostname that the Q license matches against"
}

variable "q_log_level" {
  type        = string
  description = "Level to log [silent,debug,info]"
  default     = "info"
}

variable "bundler_use_flash_loans" {
  type        = bool
  description = "Enable flash loans for triangular arbs"
  default     = false
}

variable "dual_block_submission" {
  type        = bool
  description = "Enable submission of bundle for target block and target block + 1"
  default     = true
}

variable "bundler_disable_sandwiches" {
  type        = bool
  description = "Disable sandwich bundles"
  default     = true
}

variable "enabled" {
  type        = bool
  description = "Whether or not to run an instance of the engine"
  default     = false
}
