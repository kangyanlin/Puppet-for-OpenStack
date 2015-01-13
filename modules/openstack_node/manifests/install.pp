class openstack_node::install{
  include base_install, sql_install, nova_install, telemetry_install
}

class base_install{
  package { ['ntp', 'yum-plugin-priorities', 'openstack-utils', 'openstack-selinux']:
    ensure => installed,
  }
}

class sql_install{
  package { ['MySQL-python']:
    ensure => installed,
  }
}

class nova_install{
  package { ['openstack-nova-compute', 'openstack-nova-network', 'openstack-nova-api']:
    ensure => installed;
  }
}

class telemetry_install{
  package { ['openstack-ceilometer-compute', 'python-ceilometerclient', 'python-pecan']:
    ensure => installed;
  }
}
