variable "instance_count" {
  type    = number
  default = 0
}

variable "instances" {
  type = list(object({
    hostname   = string
    connection = any
  }))
}

variable "server_address" {
  type = string
}

variable "ca_server_address" {
  type = string
}

variable "server_port" {
  type    = number
  default = 8140
}

variable "ca_server_port" {
  type    = number
  default = 8140
}

variable "environment" {
  type = string
}

variable "role" {
  type = string
}

variable "autosign_psk" {
  type = string
}

# Workaround to create explicit dependencies
variable "deps_on" {
  type    = list(string)
  default = []
}
