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
