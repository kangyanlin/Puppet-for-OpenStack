class openstack_node::params{
  $hostip = "${::ipaddress_eth0}"
  $hostnm = "${::fqdn}"
  $masterip = '10.2.20.59'
  $masternm = "host01.server.cs2c"
}
