node 'host01.server.cs2c' {
  include openstack_master
  file {"/tmp/openstack_master": content => "openstack master!";} 
}

# COMPUTE NODE #
#node 'host02.server.cs2c' {
#  include openstack_node
#  file {"/tmp/openstack_node": content => "openstack node!";}
#}
