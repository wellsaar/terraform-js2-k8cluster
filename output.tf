################
 #Output
 ################


 output "floating_ip_ubuntu20_leader" {
   value = openstack_networking_floatingip_v2.terraform_floatip_ubuntu20_leader.*.address
   description = "Public IP for Ubuntu 20 leader"
 }

 output "floating_ip_ubuntu20_follower" {
   value = openstack_networking_floatingip_v2.terraform_floatip_ubuntu20_follower.*.address
   description = "Public IP for Ubuntu 20 followers"
 }

 resource "local_file" "ansible_inventory" {
   content = templatefile("${path.module}/inventory.tftpl",
   {
     ansible_leader_ip    = openstack_networking_floatingip_v2.terraform_floatip_ubuntu20_leader.*.address,
     ansible_follower_ip  = openstack_networking_floatingip_v2.terraform_floatip_ubuntu20_follower.*.address,
   }
   )
   filename  = "ansible/inventory.ini"
 }
