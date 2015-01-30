class openstack_master::install{
  include base_install, openstack_install
}

class base_install{
  package { ['ntp', 'yum-plugin-priorities', 'openstack-utils', 'openstack-selinux', 'mysql-server', 'mysql', 'MySQL-python', 'qpid-cpp-server']:
    require => Class['yum_config'],
    ensure  => installed,
  }
}

class openstack_install{
  package { ['openstack-keystone', 'python-keystoneclient', 'openstack-glance', 'python-glanceclient', 'openstack-nova-api', 'openstack-nova-cert', 'openstack-nova-conductor', 'openstack-nova-console', 'openstack-nova-novncproxy', 'openstack-nova-scheduler', 'python-novaclient', 'memcached', 'python-memcached', 'mod_wsgi', 'openstack-dashboard', 'openstack-ceilometer-api', 'openstack-ceilometer-collector', 'openstack-ceilometer-notification', 'openstack-ceilometer-central', 'openstack-ceilometer-alarm', 'python-ceilometerclient', 'mongodb-server', 'mongodb']:
    require => Class['base_install'],
    ensure  => installed,
  }
}
