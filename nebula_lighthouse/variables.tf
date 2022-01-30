variable "name" {
  type        = string
  default     = "nblh"
  description = "Name to use with resources, something that identifies it as a nebula lighthouse"
}

variable "environment" {
  type        = string
  default     = "main"
  description = "which copy of the lighthouse is this, ie main, stage, dev"
}

variable "do_token" {}

variable "region" {
  default = "sfo3"
}

variable "ssh_public_key" {
  type        = string
  description = "public key string in an openssh authorized_key format"
}

variable "ca_crt_base64" {}
variable "host_crt_base64_arn" {}
variable "host_key_base64_arn" {}

variable "nebula_lh_ip" {
  type        = string
  description = "ip, no cidr, of the lighthouse on the nebula network"
}

variable "nebula_monitoring_groups" {
  type        = list(string)
  default     = ["monitoring"]
  description = "all in list of groups must match to allow incoming monitoring"
}

variable "nebula_mgmt_groups" {
  type        = list(string)
  default     = ["mgmt"]
  description = "all in list of groups must match to allow incoming ssh"
}

variable "nebula_version" {
  default = "1.5.2"
  type    = string
  validation {
    condition = (
      substr(var.nebula_version, 0, 1) != "v"
    )
    error_message = "The nebula version string must not start with \"v\"."
  }
  description = "Nebula version string, like 1.5.2"
}

variable "nebula_sshd_authorized_keys_list" {
  type = list(object({
    user = string
    keys = list(string)
  }))
  default = []
}