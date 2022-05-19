################
#Networking
################
#creating the virtual network
resource "openstack_networking_network_v2" "terraform_network" {
  name = "terraform_network_${var.public_key}"
  admin_state_up  = "true"
}

#creating the virtual subnet
resource "openstack_networking_subnet_v2" "terraform_subnet1" {
  name = "terraform_subnet1"
  network_id  = "${openstack_networking_network_v2.terraform_network.id}"
  cidr  = "192.168.0.0/24"
  ip_version  = 4
}
# setting up virtual router
resource "openstack_networking_router_v2" "terraform_router" {
  name = "terraform_router_${var.public_key}"
  admin_state_up  = true
  # id of public network at IU
  external_network_id = "3fe22c05-6206-4db2-9a13-44f04b6796e6"
}
# setting up virtual router interface
resource "openstack_networking_router_interface_v2" "terraform_router_interface_1" {
  router_id = "${openstack_networking_router_v2.terraform_router.id}"
  subnet_id = "${openstack_networking_subnet_v2.terraform_subnet1.id}"
}
