variable "ca_name" {
  default = "my_nebula_org"
  type    = string
  # need to add constraint for no spaces
}

variable "ipv4_range" {
  description = "like 192.168.2.0/24"
  type        = string
}

variable "host_map" {
  type = map(object({
    hostname = string
    ip       = string
    groups   = list(string)
    serial   = string
  }))
  description = "host: nebula_ip"
  default     = {}
}