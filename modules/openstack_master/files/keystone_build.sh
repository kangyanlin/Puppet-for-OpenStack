#!/bin/bash

# Values

ADMIN="admin"
PASSWD="zeastion"
EMAIL="zeastion@live.cn"

HOSTIP=`ifconfig|grep 'inet addr:'|grep -v '127.0.0.1'|grep -v '192.168.122.1'|cut -d: -f2|awk '{print $1}'`
ADMIN_TOKEN=`more /tmp/openstack.zea|grep 'ADMIN_TOKEN'|awk '{print $3}'`

keystone --os-username=$ADMIN --os-password=$PASSWD --os-auth-url=http://$HOSTIP:35357/v2.0 token-get
if [ $? -eq 0 ];then
#  echo "Keystone has already been built" >> /tmp/openstack.zea
  exit
else
  echo "Keystone hasn't been built" >> /tmp/openstack.zea
fi

# Export

export OS_SERVICE_TOKEN=$ADMIN_TOKEN
export OS_SERVICE_ENDPOINT=http://$HOSTIP:35357/v2.0

# Keystone

keystone user-create --name=$ADMIN --pass=$PASSWD --email=$EMAIL
keystone role-create --name=admin
keystone tenant-create --name=admin --description="Admin Tenant"
keystone user-role-add --user=$ADMIN --tenant=admin --role=admin
keystone user-role-add --user=$ADMIN --tenant=admin --role=_member_

keystone user-create --name=demo --pass=$PASSWD --email=$EMAIL
keystone tenant-create --name=demo --description="Demo Tenant"
keystone user-role-add --user=demo --role=_member_ --tenant=demo

keystone tenant-create --name=service --description="Service Tenant"

keystone service-create --name=keystone --type=identity --description="OpenStack Identity"
keystone endpoint-create --service-id=$(keystone service-list | awk '/ identity / {print $2}') --publicurl=http://$HOSTIP:5000/v2.0 --internalurl=http://$HOSTIP:5000/v2.0 --adminurl=http://$HOSTIP:35357/v2.0

if [ $? -ne 0 ];then
  echo "Create KEYSTONE endpoint failed" >> /tmp/openstack.zea
  exit
else
  echo "Create KEYSTONE endpoint successfully" >> /tmp/openstack.zea
fi

# Glance

keystone user-create --name=glance --pass=glance --email=$EMAIL
keystone user-role-add --user=glance --tenant=service --role=admin
keystone service-create --name=glance --type=image --description="OpenStack Image Service"
keystone endpoint-create --service-id=$(keystone service-list | awk '/ image / {print $2}') --publicurl=http://$HOSTIP:9292 --internalurl=http://$HOSTIP:9292 --adminurl=http://$HOSTIP:9292

if [ $? -ne 0 ];then
  echo "Create GLANCE endpoint failed" >> /tmp/openstack.zea
  exit
else
  echo "Create GLANCE endpoint successfully" >> /tmp/openstack.zea
fi

# Nova

keystone user-create --name=nova --pass=nova --email=$EMAIL
keystone user-role-add --user=nova --tenant=service --role=admin
keystone service-create --name=nova --type=compute --description="OpenStack Compute"
keystone endpoint-create --service-id=$(keystone service-list | awk '/ compute / {print $2}') --publicurl=http://$HOSTIP:8774/v2/%\(tenant_id\)s --internalurl=http://$HOSTIP:8774/v2/%\(tenant_id\)s --adminurl=http://$HOSTIP:8774/v2/%\(tenant_id\)s
if [ $? -ne 0 ];then
  echo "Create NOVA endpoint failed" >> /tmp/openstack.zea
  exit
else
  echo "Create NOVA endpoint successfully" >> /tmp/openstack.zea
fi

# Telemetry

keystone user-create --name=ceilometer --pass=ceilometer --email=$EMAIL
keystone user-role-add --user=ceilometer --tenant=service --role=admin
keystone service-create --name=ceilometer --type=metering --description="Telemetry"
keystone endpoint-create --service-id=$(keystone service-list | awk '/ metering / {print $2}') --publicurl=http://$HOSTIP:8777 --internalurl=http://$HOSTIP:8777 --adminurl=http://$HOSTIP:8777
if [ $? -ne 0 ];then
  echo "Create TELEMETRY endpoint failed" >> /tmp/openstack.zea
  exit
else
  echo "Create TELEMETRY endpoint successfully" >> /tmp/openstack.zea
fi

# Source file

echo -e "export OS_USERNAME=$ADMIN\nexport OS_PASSWORD=$PASSWD\nexport OS_TENANT_NAME=admin\nexport OS_AUTH_URL=http://$HOSTIP:35357/v2.0" > /tmp/admin.sh
