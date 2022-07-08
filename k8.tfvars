# replace this with the name of the public ssh key you uploaded to Jetstream 2
# https://docs.jetstream-cloud.org/ui/cli/managing-ssh-keys/
public_key = "wellsaar"

# change this if you would like to change the flavor of the leader and followers
# You can get a list of flavors with the following command
# openstack flavor list
leader_flavor = "3"
follower_flavor = "2"

# number of followers for the cluster
vm_number = "5"

