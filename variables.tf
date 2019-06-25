variable "instance_count" {
  type = number
}

variable "instances" {
  type = list(object({
    hostname   = string
    connection = any
  }))
}

variable "puppet" {
  type = object({
    server       = string
    role         = string
    environment  = string
    caserver     = string
    autosign_psk = string
  })
}

# Workaround to create explicit dependencies
variable "deps_on" {
  type    = list(string)
  default = []
}
