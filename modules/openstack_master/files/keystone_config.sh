#!/bin/bash

HOSTNAME=`hostname`
HOSTIP=`ifconfig|grep 'inet addr:'|grep -v '127.0.0.1'|grep -v '192.168.122.1'|cut -d: -f2|awk '{print $1}'`
ADMIN_TOKEN=$(openssl rand -hex 10)

# Set FQDN

echo -e "$HOSTIP\t$HOSTNAME" >> /etc/hosts

# Modify keystone configuration files

openstack-config --set /etc/keystone/keystone.conf database connection mysql://keystone:keystone@localhost/keystone
echo "Keystone connect to MySQL" >> /tmp/openstack.zea

# Create keystone database & Grant

/usr/bin/mysql -uroot -pzeastion <<EOF
create database keystone;
grant all privileges on keystone.* to 'keystone'@'localhost' identified by 'keystone';
grant all privileges on keystone.* to 'keystone'@'%' identified by 'keystone';
grant all privileges on keystone.* to 'keystone'@$HOSTIP identified by 'keystone';
flush privileges;
EOF

if [ $? -eq 0 ];then
  echo "Create database and grant all privileges to user keystone" >> /tmp/openstack.zea
fi

# Database SYNC

su -s /bin/sh -c "keystone-manage db_sync" keystone
if [ $? -eq 0 ];then
  echo "Keystone database sync" >> /tmp/openstack.zea
else
  echo "Keystone db sync error" >> /tmp/openstack.zea
  exit
fi
sleep 0.5

openstack-config --set /etc/keystone/keystone.conf DEFAULT admin_token $ADMIN_TOKEN
if [ $? -eq 0 ];then
  echo -e "ADMIN_TOKEN is $ADMIN_TOKEN" >> /tmp/openstack.zea
fi

keystone-manage pki_setup --keystone-user keystone --keystone-group keystone
sleep 0.5
chown -R keystone:keystone /etc/keystone/ssl
chmod -R o-rwx /etc/keystone/ssl
