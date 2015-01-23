class openstack_node::config{
  include net_c_config, nova_c_config, telemetry_c_config
}

class net_c_config{
  file { '/etc/sysconfig/network-scripts/ifcfg-eth1':
    ensure  => present,
    content => template('openstack_master/ifcfg-eth1.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Class['net_c_service'],
  }
}

class nova_c_config{
  file { 'nova_c_config.sh':
    ensure  => present,
    mode    => '0755',
    path    => '/tmp/nova_c_config.sh',
    source  => 'puppet:///modules/openstack_node/nova_c_config.sh',
  }
  exec { 'nova_c_config':
    require => Class['nova_c_install'],
    creates => '/tmp/openstack_c.zea',
    command => '/bin/sh /tmp/nova_c_config.sh',
    notify  => Class['nova_c_service'],
  }
}

class telemetry_c_config{
  file { 'telemetry_c_config.sh':
    ensure  => present,
    mode    => '0755',
    path    => '/tmp/telemetry_c_config.sh',
    source  => 'puppet:///modules/openstack_node/telemetry_c_config.sh',
  }
  exec { 'telemetry_c_config':
    require => Class['telemetry_c_install'],
    unless  => '/bin/more /tmp/openstack_c.zea|/bin/grep Telemetry',
    command => '/bin/sh /tmp/telemetry_c_config.sh',
    notify  => Service['openstack-nova-compute', 'openstack-ceilometer-compute'],
  }
}
