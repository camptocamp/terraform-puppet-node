terraform {
  required_providers {
    null = {
      source = "hashicorp/null"
    }

    puppetdb = {
      source = "camptocamp/puppetdb"
    }

    puppetca = {
      source = "camptocamp/puppetca"
    }
  }
}
