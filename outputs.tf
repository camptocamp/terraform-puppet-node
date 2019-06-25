output "this_provisioner_id" {
  value = null_resource.provisioner[*].id
}
