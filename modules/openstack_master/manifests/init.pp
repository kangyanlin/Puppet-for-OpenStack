class openstack_master{
  include openstack_master::install, openstack_master::config, openstack_master::service
}
