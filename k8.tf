################
#VMs
################
# creating leader

resource "openstack_compute_instance_v2" "Ubuntu20_leader" {
  name = "terraform_Ubuntu20_leader"
  # ID of JS-API-Featured-Ubuntu20-Latest
  image_id  = "69b7fce4-3bfd-467e-bc5e-13e08ac44490"
  flavor_id   = 3
  # you'll need to set this to your public key name on jetstream
  key_pair  = var.public_key
  security_groups   = ["terraform_ssh_ping", "default"]
  metadata = {
    terraform_controlled = "yes"
    ansible_role = "leader"
  }
  network {
    name = "terraform_network"
  }
  depends_on = [openstack_networking_network_v2.terraform_network]

}

resource "openstack_networking_floatingip_v2" "terraform_floatip_ubuntu20_leader" {
  pool = "public"
}

# assigning floating ip from public pool to Ubuntu20 VM
resource "openstack_compute_floatingip_associate_v2" "terraform_floatubntu20_leader" {
  floating_ip = "${openstack_networking_floatingip_v2.terraform_floatip_ubuntu20_leader.address}"
  instance_id = "${openstack_compute_instance_v2.Ubuntu20_leader.id}"
}



# creating Ubuntu20 instance
resource "openstack_compute_instance_v2" "Ubuntu20_follower" {
  name = "terraform_Ubuntu20_follower${count.index}"
  # ID of JS-API-Featured-Ubuntu20-Latest
  image_id  = "69b7fce4-3bfd-467e-bc5e-13e08ac44490"
  flavor_id   = 2
  # this public key is set above in security section
  key_pair  = var.public_key
  security_groups   = ["terraform_ssh_ping", "default"]
  count     = var.vm_number
  metadata = {
    terraform_controlled = "yes"
    ansible_role = "follower"
  }
  network {
    name = "terraform_network"
  }
  depends_on = [openstack_networking_network_v2.terraform_network]

}
# creating floating ip from the public ip pool
resource "openstack_networking_floatingip_v2" "terraform_floatip_ubuntu20_follower" {
  pool = "public"
    count     = var.vm_number
}

# assigning floating ip from public pool to Ubuntu20 VM
resource "openstack_compute_floatingip_associate_v2" "terraform_floatubntu20_follower" {
  floating_ip = "${openstack_networking_floatingip_v2.terraform_floatip_ubuntu20_follower[count.index].address}"
  instance_id = "${openstack_compute_instance_v2.Ubuntu20_follower[count.index].id}"
    count     = var.vm_number
}

resource "null_resource" "ansible_provisioners" {
  provisioner "remote-exec" {
    inline = [
      "echo \"Checking if cloud init is running\"",
      "sudo cloud-init status --wait",
      "sudo apt update",
      "sudo apt install python3 ansible -y",
      "rm -rf ~/ansible"
    ]
      connection {
        type = "ssh"
        host = "${openstack_networking_floatingip_v2.terraform_floatip_ubuntu20_leader.address}"
        user = "ubuntu"
      }
  }
  provisioner "file" {
    source = "ansible"
    destination = "ansible"
  }
      connection {
        type = "ssh"
        host = "${openstack_networking_floatingip_v2.terraform_floatip_ubuntu20_leader.address}"
        user = "ubuntu"
      }
  provisioner "remote-exec" {
    inline = [
      "ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook -i ansible/inventory.ini ansible/k8_setup.yaml ",
      "ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook -i ansible/inventory.ini ansible/leader.yaml ",
      "ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook -i ansible/inventory.ini ansible/follower.yaml "
    ]
      connection {
        type = "ssh"
        host = "${openstack_networking_floatingip_v2.terraform_floatip_ubuntu20_leader.address}"
        user = "ubuntu"
      }
    }

  depends_on = [openstack_compute_floatingip_associate_v2.terraform_floatubntu20_leader]
}
