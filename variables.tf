variable "connection" {
  type = list
}

variable "instance_count" {
  type = number
}

variable "puppet_role" {
  type = string
}

variable "puppet_environment" {
  type = string
}

variable "puppet_caserver" {
  type = string
}

variable "puppet_server" {
  type = string
}

variable "hostnames" {
  type = list(string)
}

variable "puppet_autosign_psk" {
  type = string
}
