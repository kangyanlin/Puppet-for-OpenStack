# Master #
node 'host01.server.cs2c' {
  include openstack_master
  file {"/tmp/openstack_master": content => "openstack master-1";} 
}

# COMPUTE NODE #
node 'host02.server.cs2c' {
  include openstack_node
  file {"/tmp/openstack_node": content => "openstack node-2";}
}
node 'host03.server.cs2c' {
  include openstack_node
  file {"/tmp/openstack_node": content => "openstack node-3";}
}
