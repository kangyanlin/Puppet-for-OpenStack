class openstack_master::config{
  include sql_config, mess_config, keystone_config, keystone_build, glance_config, nova_config, dashboard_config, telemetry_config
        #net_config
}

#class net_config{
#  file { '/etc/sysconfig/network-scripts/ifcfg-eth1':
#    ensure  => present,
#    content => template('openstack_master/ifcfg-eth1.erb'),
#    owner   => 'root',
#    group   => 'root',
#    mode    => '0644',
#    notify  => Class['net_service'],
#  }
#}

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
    path    => '/usr/bin',
    unless  => 'mysqladmin -uroot -pzeastion status',
    command => 'mysqladmin -u root password "zeastion"',
    require => Class['sql_service'],
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
  file { 'keystone_config.sh':
    ensure  => present,
    mode    => '755',
    path    => '/tmp/keystone_config.sh',
    source  => 'puppet:///modules/openstack_master/keystone_config.sh',
  }
  exec { 'keystone_config':
    require => Class['keystone_install', 'sql_config'],
#    onlyif  => '/usr/bin/mysql -uroot -pzeastion',
    unless  => '/usr/bin/mysql -ukeystone -pkeystone',
    command => '/bin/sh /tmp/keystone_config.sh',
    creates => '/tmp/openstack.zea',
    notify  => Class['keystone_service'],
  }
}

class keystone_build{
  file { 'keystone_build.sh':
    ensure  => present,
    mode    => '755',
    path    => '/tmp/keystone_build.sh',
    source  => 'puppet:///modules/openstack_master/keystone_build.sh',
  }
  exec { 'keystone_build':
    require => Class['keystone_config', 'keystone_service'],
    command => '/bin/sh /tmp/keystone_build.sh',
  }
}

class glance_config{
  file { 'glance_config.sh':
    ensure  => present,
    mode    => '755',
    path    => '/tmp/glance_config.sh',
    source  => 'puppet:///modules/openstack_master/glance_config.sh',
  }
  exec { 'glance_config':
    require => Class['keystone_build'],
    unless  => '/usr/bin/mysql -uglance -pglance',
    command => '/bin/sh /tmp/glance_config.sh',
  }
}

class nova_config{
  file { 'nova_config.sh':
    ensure  => present,
    mode    => '755',
    path    => '/tmp/nova_config.sh',
    source  => 'puppet:///modules/openstack_master/nova_config.sh',
  }
  exec { 'nova_config':
    require => Class['keystone_build'],
    unless  => '/usr/bin/mysql -unova -pnova',
    command => '/bin/sh /tmp/nova_config.sh',
  }
}

class dashboard_config{
  file { 'local_settings':
    ensure  => present,
    content => template('openstack_master/local_settings.erb'),
    path    => '/etc/openstack-dashboard/local_settings',
    owner   => 'root',
    group   => 'apache',
    mode    => '0640',
    require => Class['dashboard_install'],
    notify  => Service['httpd'],
  }
}

class telemetry_config{
  include openstack_master::params
  file { 'mongodb.conf':
    ensure  => present,
    content => template('openstack_master/mongodb.conf.erb'),
    path    => '/etc/mongodb.conf',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Class['telemetry_install'],
    notify  => Service['mongod'],
  }
  file { 'telemetry_config.sh':
    ensure  => present,
    mode    => '755',
    path    => '/tmp/telemetry_config.sh',
    source  => 'puppet:///modules/openstack_master/telemetry_config.sh',
  }
  exec { 'telemetry_config':
    require => Service['mongod'],
    unless  => '/bin/more /tmp/openstack.zea|/bin/grep MongoDB',
    command => '/bin/sh /tmp/telemetry_config.sh',
  }
}
