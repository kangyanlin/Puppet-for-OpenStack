class openstack_node::service{
  include net_c_service, ntp_c_service, nova_c_service, telemetry_c_service
}

class net_c_service{
  service{ 'NetworkManager':
    ensure    => stopped,
    enable    => false,
    hasstatus => true,
  }
  service{ 'network':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}

class ntp_c_service{
  service{ 'ntpd':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
  }
}

class nova_c_service{
  service{ ['libvirtd', 'messagebus', 'openstack-nova-compute', 'openstack-nova-network', 'openstack-nova-metadata-api']:
    require    => Class['nova_c_config'],
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}

class telemetry_c_service{
  service{ 'openstack-ceilometer-compute':
    require    => Class['telemetry_c_config'],
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
