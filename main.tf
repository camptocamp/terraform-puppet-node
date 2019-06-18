resource "puppetdb_node" "this" {
  count = length(var.instances)

  certname = var.instances[count.index].hostname
}

resource "puppetca_certificate" "this" {
  count = length(var.instances)


  name = var.instances[count.index].hostname
}

resource "null_resource" "provisioner" {
  count = length(var.instances)

  connection {
    type                = lookup(var.instances[count.index].connection, "type", null)
    user                = lookup(var.instances[count.index].connection, "user", "terraform")
    password            = lookup(var.instances[count.index].connection, "password", null)
    host                = lookup(var.instances[count.index].connection, "host", null)
    port                = lookup(var.instances[count.index].connection, "port", 22)
    timeout             = lookup(var.instances[count.index].connection, "timeout", null)
    script_path         = lookup(var.instances[count.index].connection, "script_path", null)
    private_key         = lookup(var.instances[count.index].connection, "private_key", null)
    agent               = lookup(var.instances[count.index].connection, "agent", true)
    agent_identity      = lookup(var.instances[count.index].connection, "agent_identity", null)
    host_key            = lookup(var.instances[count.index].connection, "host_key", null)
    https               = lookup(var.instances[count.index].connection, "https", false)
    insecure            = lookup(var.instances[count.index].connection, "insecure", false)
    use_ntlm            = lookup(var.instances[count.index].connection, "use_ntlm", false)
    cacert              = lookup(var.instances[count.index].connection, "cacert", null)
    bastion_host        = lookup(var.instances[count.index].connection, "bastion_host", null)
    bastion_host_key    = lookup(var.instances[count.index].connection, "bastion_host_key", null)
    bastion_port        = lookup(var.instances[count.index].connection, "bastion_port", 22)
    bastion_user        = lookup(var.instances[count.index].connection, "bastion_user", null)
    bastion_password    = lookup(var.instances[count.index].connection, "bastion_password", null)
    bastion_private_key = lookup(var.instances[count.index].connection, "bastion_private_key", null)
  }

  provisioner "ansible" {
    plays {
      playbook {
        file_path  = "${path.module}/ansible-data/playbooks/puppet-node.yml"
        roles_path = ["${path.module}/ansible-data/roles"]
      }

      groups = ["puppet-node"]
      become = true
      diff   = true

      extra_vars = {
        hostname = var.instances[count.index].hostname

        puppet_autosign_challenge = "${format("hashed;%s", base64sha256(format("%s/%s/%s/%s", var.puppet.autosign_psk, var.instances[count.index].hostname, var.puppet.role, var.puppet.environment)))}"
        puppet_role               = var.puppet.role
        puppet_environment        = var.puppet.environment
        puppet_caserver           = var.puppet.caserver
        puppet_server             = var.puppet.server
      }
    }
  }
}