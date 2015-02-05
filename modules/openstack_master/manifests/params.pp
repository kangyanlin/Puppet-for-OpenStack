class openstack_master::params{
  $masterip = "${::ipaddress_eth0}"
  $masternm = "${::fqdn}"
}
