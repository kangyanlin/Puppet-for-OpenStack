class openstack_node::install{
  include base_c_install, sql_c_install, nova_c_install, telemetry_c_install
}

class base_c_install{
  package { ['ntp', 'yum-plugin-priorities', 'openstack-utils', 'openstack-selinux']:
    ensure => installed,
  }
}

class sql_c_install{
  package { ['MySQL-python']:
    ensure => installed,
  }
}

class nova_c_install{
  package { ['openstack-nova-compute', 'openstack-nova-network', 'openstack-nova-api']:
    ensure => installed;
  }
}

class telemetry_c_install{
  package { ['openstack-ceilometer-compute', 'python-ceilometerclient', 'python-pecan']:
    ensure => installed;
  }
}
