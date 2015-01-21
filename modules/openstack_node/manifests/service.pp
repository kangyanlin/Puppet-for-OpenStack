class openstack_master::service{
  include net_service, ntp_service
}

class net_service{
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

class ntp_service{
  service{ 'ntpd':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
  }
}
