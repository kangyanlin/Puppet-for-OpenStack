class openstack_node::config{
  include net_config
}

class net_config{
  file { '/etc/sysconfig/network-scripts/ifcfg-eth1':
    ensure  => present,
    content => template('openstack_master/ifcfg-eth1.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Class['net_service'],
  }
}

