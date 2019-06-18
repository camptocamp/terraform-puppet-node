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
  source = "git::ssh://git@github.com/camptocamp/terraform-instance-aws.git"

  security_groups     = ["sg-064a964f60b3b4d6f"]
  instance_count      = var.instance_count
  instance_image      = data.aws_ami.ami.id
  instance_subnet_ids = ["subnet-0ae8b71b5b9926c31"]
  instance_type       = "t2.micro"
  key_pair            = var.key_pair
  ebs_optimized       = false
}

module "puppet-node" {
  source = "../"

  instance_count = var.instance_count
  hostnames      = module.instance.private_dns

  puppet_autosign_psk = data.pass_password.puppet_autosign_psk.data["puppet_autosign_psk"]
  puppet_server       = "puppet.camptocamp.net"
  puppet_caserver     = "puppetca.camptocamp.net"
  puppet_role         = "base"
  puppet_environment  = "staging4"

  connection = [
    for i in range(var.instance_count) :
    {
      host = module.instance.public_ips[i]
    }
  ]
}

###
# Acceptance test
#
resource "null_resource" "acceptance" {
  depends_on = [module.instance]
  count      = var.instance_count

  connection {
    host = module.instance.public_ips[count.index]
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
