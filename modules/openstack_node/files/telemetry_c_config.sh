#!/bin/bash

# Values

MASTERIP="10.2.20.175"
CEILOMETER_TOKEN="ZEASTION"

# Modify NOVA configuration file for Telemetry

openstack-config --set /etc/nova/nova.conf DEFAULT instance_usage_audit True
openstack-config --set /etc/nova/nova.conf DEFAULT instance_usage_audit_period hour
openstack-config --set /etc/nova/nova.conf DEFAULT notify_on_state_change vm_and_task_state

sed -i "/notify_on_state_change = vm_and_task_state/a notification_driver=nova.openstack.common.notifier.rpc_notifier\nnotification_driver=ceilometer.compute.nova_notifier" /etc/nova/nova.conf
echo "Telemetry for Nova Compute" >> /tmp/openstack_c.zea

# Modify TELEMETRY configuration files

openstack-config --set /etc/ceilometer/ceilometer.conf publisher metering_secret $CEILOMETER_TOKEN
openstack-config --set /etc/ceilometer/ceilometer.conf DEFAULT rpc_backend ceilometer.openstack.common.rpc.impl_qpid
openstack-config --set /etc/ceilometer/ceilometer.conf DEFAULT qpid_hostname $MASTERIP
openstack-config --set /etc/ceilometer/ceilometer.conf keystone_authtoken auth_host $MASTERIP
openstack-config --set /etc/ceilometer/ceilometer.conf keystone_authtoken admin_user ceilometer
openstack-config --set /etc/ceilometer/ceilometer.conf keystone_authtoken admin_tenant_name service
openstack-config --set /etc/ceilometer/ceilometer.conf keystone_authtoken auth_protocol http
openstack-config --set /etc/ceilometer/ceilometer.conf keystone_authtoken admin_password ceilometer
openstack-config --set /etc/ceilometer/ceilometer.conf service_credentials os_username ceilometer
openstack-config --set /etc/ceilometer/ceilometer.conf service_credentials os_tenant_name service
openstack-config --set /etc/ceilometer/ceilometer.conf service_credentials os_password ceilometer
openstack-config --set /etc/ceilometer/ceilometer.conf service_credentials os_auth_url http://$MASTERIP:5000/v2.0
echo "Modify TELEMETRY configuration files successfully" >> /tmp/openstack_c.zea
