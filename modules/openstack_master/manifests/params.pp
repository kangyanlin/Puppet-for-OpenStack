class openstack_master::params{
  $masterip = "${::ipaddress_eth0}"
  $masternm = "${::fqdn}"
  $admin = "admin"
  $passwd = "zeastion"
  $email = "zeastion@live.cn"
}
