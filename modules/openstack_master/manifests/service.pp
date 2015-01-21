class openstack_master::service{
  include net_service, ntp_service, sql_service, mess_service, keystone_service, glance_service, nova_service, dashboard_service, telemetry_service
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

class sql_service{
  service{ 'mysqld':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
  }
}

class mess_service{
  service{ 'qpidd':
    require    => Class['mess_config'],
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}

class keystone_service{
  service{ 'openstack-keystone':
    require    => Class['keystone_config'],
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}

class glance_service{
  service{ ['openstack-glance-api', 'openstack-glance-registry']:
    require    => Class['glance_config'],
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
#  service{ 'openstack-glance-registry':
#    require    => Class['glance_config'],
#    ensure     => running,
#    enable     => true,
#    hasstatus  => true,
#    hasrestart => true,
#  }
}

class nova_service{
  service{ ['openstack-nova-api', 'openstack-nova-cert', 'openstack-nova-consoleauth', 'openstack-nova-scheduler', 'openstack-nova-conductor', 'openstack-nova-novncproxy']:
    require    => Class['nova_config'],
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}

class dashboard_service{
  service{ ['httpd', 'memcached']:
    require    => Class['dashboard_config'],
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}

class telemetry_service{
  service{ ['mongod']:
    require    => File['mongodb.conf'],
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
  service{ ['openstack-ceilometer-api', 'openstack-ceilometer-notification', 'openstack-ceilometer-central', 'openstack-ceilometer-collector', 'openstack-ceilometer-alarm-evaluator', 'openstack-ceilometer-alarm-notifier']:
    require    => Class['telemetry_config'],
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
