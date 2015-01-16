class openstack_master::config{
  include net_config, sql_config, mess_config, keystone_config
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
  exec { 'set_mysql_password':
    unless  => 'mysqladmin -uroot -pzeastion status',
    path    => '/usr/bin',
    command => 'mysqladmin -u root password "zeastion"',
    require => Class['sql_service'],
  }
  file { 'keystone_sql.sh':
    ensure  => present,
    mode    => '755',
    path    => '/tmp/keystone_sql.sh',
    source  => 'puppet:///modules/openstack_master/keystone_sql.sh',
  }
  exec { 'set_database_keystone':
    onlyif  => '/usr/bin/mysql -uroot -pzeastion',
    unless  => '/usr/bin/mysql -ulzy -plzy',
    path    => '/bin',
    command => 'sh /tmp/keystone_sql.sh',
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

class keystone_config{
  exec { 'set_keystone_connection':
    require => Class['keystone_install'],
    path    => "/usr/bin",
    command => 'openstack-config --set /etc/keystone/keystone.conf database connection mysql://keystone:keystone@localhost/keystone && /bin/touch /tmp/keystone.my',
    creates => "/tmp/keystone.my",
  }
}
