class openstack_master::install{
  include base_install, sql_install, mess_install, keystone_install, glance_install, nova_install, dashboard_install, telemetry_install
}

class base_install{
  package { ['ntp', 'yum-plugin-priorities', 'openstack-utils', 'openstack-selinux']:
    ensure => installed,
  }
}

class sql_install{
  package { ['mysql-server', 'mysql', 'MySQL-python']:
    ensure => installed,
  }
}

class mess_install{
  package { ['qpid-cpp-server']:
    ensure => installed,
  }
}

class keystone_install{
  package { ['openstack-keystone', 'python-keystoneclient']:
    ensure => installed,
  }
}

class glance_install{
  package { ['openstack-glance', 'python-glanceclient']:
    ensure => installed,
  }
}

class nova_install{
  package { ['openstack-nova-api', 'openstack-nova-cert', 'openstack-nova-conductor', 'openstack-nova-console', 'openstack-nova-novncproxy', 'openstack-nova-scheduler', 'python-novaclient']:
    ensure => installed;
  }
}

class dashboard_install{
  package { ['memcached', 'python-memcached', 'mod_wsgi', 'openstack-dashboard']:
    ensure => installed;
  }
}

class telemetry_install{
  package { ['openstack-ceilometer-api', 'openstack-ceilometer-collector', 'openstack-ceilometer-notification', 'openstack-ceilometer-central', 'openstack-ceilometer-alarm', 'python-ceilometerclient', 'mongodb-server', 'mongodb']:
    ensure => installed;
  }
}
