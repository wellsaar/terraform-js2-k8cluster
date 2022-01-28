################
#Output
################


output "floating_ip_ubuntu20" {
  value = openstack_networking_floatingip_v2.terraform_floatip_ubuntu20.*.address
  description = "Public IP for Ubuntu 20"
}
