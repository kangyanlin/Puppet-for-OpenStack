#!/bin/bash

# Values

HOSTIP=`ifconfig|grep 'inet addr:'|grep -v '127.0.0.1'|grep -v '192.168.122.1'|cut -d: -f2|awk '{print $1}'`

# Modify nova configuration files

openstack-config --set /etc/nova/nova.conf database connection mysql://nova:nova@$HOSTIP/nova
echo "Nova connect to MySQL" >> /tmp/openstack.zea

openstack-config --set /etc/nova/nova.conf database connection mysql://nova:nova@$HOSTIP/nova
openstack-config --set /etc/nova/nova.conf DEFAULT rpc_backend qpid
openstack-config --set /etc/nova/nova.conf DEFAULT qpid_hostname $HOSTIP
openstack-config --set /etc/nova/nova.conf DEFAULT my_ip $HOSTIP
openstack-config --set /etc/nova/nova.conf DEFAULT vncserver_listen $HOSTIP
openstack-config --set /etc/nova/nova.conf DEFAULT vncserver_proxyclient_address $HOSTIP
openstack-config --set /etc/nova/nova.conf DEFAULT auth_strategy keystone
openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_uri http://$HOSTIP:5000
openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_host $HOSTIP
openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_protocol http
openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_port 35357
openstack-config --set /etc/nova/nova.conf keystone_authtoken admin_user nova
openstack-config --set /etc/nova/nova.conf keystone_authtoken admin_tenant_name service
openstack-config --set /etc/nova/nova.conf keystone_authtoken admin_password nova
openstack-config --set /etc/nova/nova.conf DEFAULT network_api_class nova.network.api.API
openstack-config --set /etc/nova/nova.conf DEFAULT security_group_api nova

# Create nova database & Grant

/usr/bin/mysql -u root -pzeastion <<EOF
CREATE DATABASE nova;
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY 'nova';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY 'nova';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@$HOSTIP IDENTIFIED BY 'nova';
FLUSH PRIVILEGES;
EOF

if [ $? -eq 0 ];then
  echo "Create database and grant all privileges to user nova" >> /tmp/openstack.zea
else
  echo "Database for nova - Error" >> /tmp/openstack.zea
fi

# Database SYNC

su -s /bin/sh -c "nova-manage db sync" nova

if [ $? -eq 0 ];then
  echo "Nova database sync" >> /tmp/openstack.zea
else
  echo "Nova db sync error" >> /tmp/openstack.zea
  exit
fi
sleep 0.2
