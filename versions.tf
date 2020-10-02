terraform {
  required_providers {
    null = {
      source = "hashicorp/null"
    }
    puppetca = {
      source = "camptocamp/puppetca"
    }
    puppetdb = {
      source = "camptocamp/puppetdb"
    }
  }
  required_version = ">= 0.13"
}
