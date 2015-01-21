#!/bin/bash

# Values

HOSTIP=`ifconfig|grep 'inet addr:'|grep -v '127.0.0.1'|grep -v '192.168.122.1'|cut -d: -f2|awk '{print $1}'`
CEILOMETER_TOKEN=$(openssl rand -hex 10)

# Database

mongo --host $HOSTIP --eval 'db=db.getSiblingDB("ceilometer");db.addUser({user: "ceilometer",pwd: "ceilometer",roles: [ "readWrite", "dbAdmin" ]})'

if [ $? -ne 0 ];then
  echo "Create db for CEILOMETER successfully" >> /tmp/openstack.zea
else
  echo "Create db for CEILOMETER failed" >> /tmp/openstack.zea
  exit
fi

# Modify ceilometer configuration files

penstack-config --set /etc/ceilometer/ceilometer.conf database connection mongodb://ceilometer:ceilometer@$HOSTIP:27017/ceilometer
echo "Glance connect to MongoDB" >> /tmp/openstack.zea

openstack-config --set /etc/ceilometer/ceilometer.conf publisher metering_secret $CEILOMETER_TOKEN
if [ $? -eq 0 ];then
  echo -e "CEILOMETER_TOKEN is $CEILOMETER_TOKEN" >> /tmp/openstack.zea
fi

openstack-config --set /etc/ceilometer/ceilometer.conf DEFAULT rpc_backend ceilometer.openstack.common.rpc.impl_qpid
openstack-config --set /etc/ceilometer/ceilometer.conf DEFAULT auth_strategy keystone
openstack-config --set /etc/ceilometer/ceilometer.conf keystone_authtoken auth_host $HOSTIP
openstack-config --set /etc/ceilometer/ceilometer.conf keystone_authtoken admin_user ceilometer
openstack-config --set /etc/ceilometer/ceilometer.conf keystone_authtoken admin_tenant_name service
openstack-config --set /etc/ceilometer/ceilometer.conf keystone_authtoken auth_protocol http
openstack-config --set /etc/ceilometer/ceilometer.conf keystone_authtoken auth_uri http://$HOSTIP:5000
openstack-config --set /etc/ceilometer/ceilometer.conf keystone_authtoken admin_password ceilometer
openstack-config --set /etc/ceilometer/ceilometer.conf service_credentials os_auth_url http://$HOSTIP:5000/v2.0
openstack-config --set /etc/ceilometer/ceilometer.conf service_credentials os_username ceilometer
openstack-config --set /etc/ceilometer/ceilometer.conf service_credentials os_tenant_name service
openstack-config --set /etc/ceilometer/ceilometer.conf service_credentials os_password ceilometer
