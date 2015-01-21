#!/bin/bash

# Values

HOSTIP=`ifconfig|grep 'inet addr:'|grep -v '127.0.0.1'|grep -v '192.168.122.1'|cut -d: -f2|awk '{print $1}'`

# Modify glance configuration files

openstack-config --set /etc/glance/glance-api.conf database connection mysql://glance:glance@$HOSTIP/glance
openstack-config --set /etc/glance/glance-registry.conf database connection mysql://glance:glance@$HOSTIP/glance
echo "Glance connect to MySQL" >> /tmp/openstack.zea

openstack-config --set /etc/glance/glance-api.conf keystone_authtoken auth_uri http://$HOSTIP:5000
openstack-config --set /etc/glance/glance-api.conf keystone_authtoken auth_host $HOSTIP
openstack-config --set /etc/glance/glance-api.conf keystone_authtoken auth_port 35357
openstack-config --set /etc/glance/glance-api.conf keystone_authtoken auth_protocol http
openstack-config --set /etc/glance/glance-api.conf keystone_authtoken admin_tenant_name service
openstack-config --set /etc/glance/glance-api.conf keystone_authtoken admin_user glance
openstack-config --set /etc/glance/glance-api.conf keystone_authtoken  admin_password glance
openstack-config --set /etc/glance/glance-api.conf paste_deploy flavor keystone
openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken auth_uri http://$HOSTIP:5000
openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken auth_host $HOSTIP
openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken auth_port 35357
openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken auth_protocol http
openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken admin_tenant_name service
openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken admin_user glance
openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken admin_password glance
openstack-config --set /etc/glance/glance-registry.conf paste_deploy  flavor keystone

# Create glance database & Grant

/usr/bin/mysql -u root -pzeastion <<EOF
CREATE DATABASE glance;
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'glance';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'glance';
GRANT ALL PRIVILEGES ON glance.* to 'glance'@$HOSTIP IDENTIFIED BY 'glance';
FLUSH PRIVILEGES;
EOF

if [ $? -eq 0 ];then
  echo "Create database and grant all privileges to user glance" >> /tmp/openstack.zea
else
  echo "Database for glance - Error" >> /tmp/openstack.zea
fi

# Database SYNC

su -s /bin/sh -c "glance-manage db_sync" glance
if [ $? -eq 0 ];then
  echo "Glance database sync" >> /tmp/openstack.zea
else
  echo "Glance db sync error" >> /tmp/openstack.zea
  exit
fi
sleep 0.2
