class openstack_node::install{
  include base_c_install, openstack_c_install
}

class base_c_install{
  package { ['ntp', 'ganglia', 'ganglia-gmond', 'yum-plugin-priorities', 'openstack-utils', 'openstack-selinux', 'MySQL-python']:
    require => Class['yum_c_config'],
    ensure  => installed,
  }
}

class openstack_c_install{
  package { ['openstack-nova-compute', 'openstack-nova-network', 'openstack-nova-api', 'openstack-ceilometer-compute', 'python-ceilometerclient', 'python-pecan']:
    require => Class['base_c_install'],
    ensure  => installed,
  }
}
