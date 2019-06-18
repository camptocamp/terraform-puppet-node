resource "puppetdb_node" "this" {
  count = var.instance_count

  certname = var.hostnames[count.index]
}

resource "puppetca_certificate" "this" {
  count = var.instance_count

  name = var.hostnames[count.index]
}

resource "null_resource" "provisioner" {
  count = var.instance_count

  connection {
    type                = lookup(var.connection[count.index], "type", null)
    user                = lookup(var.connection[count.index], "user", "terraform")
    password            = lookup(var.connection[count.index], "password", null)
    host                = lookup(var.connection[count.index], "host", null)
    port                = lookup(var.connection[count.index], "port", 22)
    timeout             = lookup(var.connection[count.index], "timeout", null)
    script_path         = lookup(var.connection[count.index], "script_path", null)
    private_key         = lookup(var.connection[count.index], "private_key", null)
    agent               = lookup(var.connection[count.index], "agent", true)
    agent_identity      = lookup(var.connection[count.index], "agent_identity", null)
    host_key            = lookup(var.connection[count.index], "host_key", null)
    https               = lookup(var.connection[count.index], "https", false)
    insecure            = lookup(var.connection[count.index], "insecure", false)
    use_ntlm            = lookup(var.connection[count.index], "use_ntlm", false)
    cacert              = lookup(var.connection[count.index], "cacert", null)
    bastion_host        = lookup(var.connection[count.index], "bastion_host", null)
    bastion_host_key    = lookup(var.connection[count.index], "bastion_host_key", null)
    bastion_port        = lookup(var.connection[count.index], "bastion_port", 22)
    bastion_user        = lookup(var.connection[count.index], "bastion_user", null)
    bastion_password    = lookup(var.connection[count.index], "bastion_password", null)
    bastion_private_key = lookup(var.connection[count.index], "bastion_private_key", null)
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
        hostname = var.hostnames[count.index]

        puppet_autosign_challenge = "${format("hashed;%s", base64sha256(format("%s/%s/%s/%s", var.puppet_autosign_psk, var.hostnames[count.index], var.puppet_role, var.puppet_environment)))}"
        puppet_role               = var.puppet_role
        puppet_environment        = var.puppet_environment
        puppet_caserver           = var.puppet_caserver
        puppet_server             = var.puppet_server
      }
    }
  }
}
