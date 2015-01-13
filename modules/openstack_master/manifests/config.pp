class openstack_master::config{
  include net_config, sql_config, mess_config
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

class sql_config{
  include openstack_master::params
  file { '/etc/my.cnf':
    ensure  => present,
    content => template('openstack_master/my.cnf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Class['sql_install'],
    notify  => Class['sql_service'],
  }
}

class mess_config{
  file { '/etc/qpidd.conf':
    ensure  => present,
    content => template('openstack_master/qpidd.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Class['mess_install'],
    notify  => Class['mess_service'],
  }
}
