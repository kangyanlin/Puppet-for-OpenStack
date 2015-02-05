class openstack_node::config{
  include yum_c_config, net_c_config, ganglia_c_config, nova_c_config, telemetry_c_config
}

class yum_c_config{
  file { 'yum_c_config.sh':
    ensure  => present,
    mode    => '0755',
    path    => '/tmp/yum_c_config.sh',
    source  => 'puppet:///modules/openstack_master/yum_config.sh',
  }
  exec { 'yum_c_config':
    creates => '/etc/yum.repos.d/rdo-release.repo',
    command => '/bin/sh /tmp/yum_c_config.sh',
  }
}

class net_c_config{
  file { '/etc/sysconfig/network-scripts/ifcfg-eth1':
    ensure  => present,
    content => template('openstack_node/ifcfg-eth1.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Class['net_c_service'],
  }
}

class ganglia_c_config{
  include openstack_node::params
  file { 'gmond.conf':
    ensure  => present,
    content => template('openstack_node/gmond.conf.erb'),
    path    => '/etc/ganglia/gmond.conf',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['ganglia-gmond'],
    notify  => Service['gmond'],
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
    require => Class['openstack_c_install'],
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
    require => Class['nova_c_config'],
    unless  => '/bin/more /tmp/openstack_c.zea|/bin/grep Telemetry',
    command => '/bin/sh /tmp/telemetry_c_config.sh',
    notify  => Service['openstack-nova-compute', 'openstack-ceilometer-compute'],
  }
}
