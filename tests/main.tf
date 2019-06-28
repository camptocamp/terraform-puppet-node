###
# Variables
#
variable "key_pair" {}

###
# Datasources
#
data "pass_password" "puppet_autosign_psk" {
  path = "terraform/c2c_mgmtsrv/puppet_autosign_psk"
}

###
# Code to test
#
variable "instance_count" {
  default = 1
}

data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

module "instance" {
  source         = "git::ssh://git@github.com/camptocamp/terraform-instance-aws.git"
  instance_count = var.instance_count

  security_groups     = ["sg-064a964f60b3b4d6f"]
  instance_image      = data.aws_ami.ami.id
  instance_subnet_ids = ["subnet-0ae8b71b5b9926c31"]
  instance_type       = "t2.micro"
  key_pair            = var.key_pair
  ebs_optimized       = false
}

module "puppet-node" {
  source = "../"

  instances = [
    for i in range(var.instance_count) :
    {
      hostname = module.instance.this_instance_private_dns[i]
      connection = {
        host = module.instance.this_instance_public_ip[i]
      }
    }
  ]

  autosign_psk      = data.pass_password.puppet_autosign_psk.data["puppet_autosign_psk"]
  server_address    = "puppet.camptocamp.net"
  ca_server_address = "puppetca.camptocamp.net"
  role              = "base"
  environment       = "staging4"
}

###
# Acceptance test
#
resource "null_resource" "acceptance" {
  depends_on = [module.instance]
  count      = var.instance_count

  connection {
    host = module.instance.this_instance_public_ip[count.index]
    type = "ssh"
    user = "root"
  }

  provisioner "file" {
    source      = "script.sh"
    destination = "/tmp/script.sh"
  }

  provisioner "file" {
    source      = "goss.yaml"
    destination = "/root/goss.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "sudo /tmp/script.sh",
    ]
  }
}
