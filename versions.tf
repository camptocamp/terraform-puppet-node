terraform {
  required_providers {
    puppetca = {
      source = "camptocamp/puppetca"
      version = "1.3.0"
    }
    puppetdb = {
      source = "camptocamp/puppetdb"
      version = "1.2.0"
    }
  }

  required_version = ">= 0.13"
}
