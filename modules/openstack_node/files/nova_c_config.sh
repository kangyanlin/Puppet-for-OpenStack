#!/bin/bash

# Values

HOSTNM=`hostname`
HOSTIP=`ifconfig|grep 'inet addr:'|grep -v '127.0.0.1'|grep -v '192.168.122.1'|cut -d: -f2|awk '{print $1}'`
MASTERIP="10.2.20.175"
MASTERNM="host01.server.cs2c"

# Set FQDN

echo -e "$MASTERIP\t$MASTERNM\n$HOSTIP\t$HOSTNM" >> /etc/hosts

echo -e "MASTERIP is $MASTERIP | HOSTIP is $HOSTIP" >> /tmp/openstack_c.zea

# Modify nova (compute node) configuration files

openstack-config --set /etc/nova/nova.conf database connection mysql://nova:nova@$MASTERIP/nova
openstack-config --set /etc/nova/nova.conf DEFAULT auth_strategy keystone
openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_uri http://$MASTERIP:5000
openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_host $MASTERIP
openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_protocol http
openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_port 35357
openstack-config --set /etc/nova/nova.conf keystone_authtoken admin_user nova
openstack-config --set /etc/nova/nova.conf keystone_authtoken admin_tenant_name service
openstack-config --set /etc/nova/nova.conf keystone_authtoken admin_password nova
openstack-config --set /etc/nova/nova.conf DEFAULT rpc_backend qpid
openstack-config --set /etc/nova/nova.conf DEFAULT qpid_hostname $MASTERIP
openstack-config --set /etc/nova/nova.conf DEFAULT my_ip $HOSTIP
openstack-config --set /etc/nova/nova.conf DEFAULT vnc_enabled True
openstack-config --set /etc/nova/nova.conf DEFAULT vncserver_listen 0.0.0.0
openstack-config --set /etc/nova/nova.conf DEFAULT vncserver_proxyclient_address $HOSTIP
openstack-config --set /etc/nova/nova.conf DEFAULT vncproxy_base_url http://$MASTERIP:6080/vnc_auto.html
openstack-config --set /etc/nova/nova.conf DEFAULT glance_host $MASTERIP

openstack-config --set /etc/nova/nova.conf DEFAULT network_api_class nova.network.api.API
openstack-config --set /etc/nova/nova.conf DEFAULT security_group_api nova
openstack-config --set /etc/nova/nova.conf DEFAULT network_manager nova.network.manager.FlatDHCPManager
openstack-config --set /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.libvirt.firewall.IptablesFirewallDriver
openstack-config --set /etc/nova/nova.conf DEFAULT network_size 254
openstack-config --set /etc/nova/nova.conf DEFAULT allow_same_net_traffic False
openstack-config --set /etc/nova/nova.conf DEFAULT multi_host True
openstack-config --set /etc/nova/nova.conf DEFAULT send_arp_for_ha True
openstack-config --set /etc/nova/nova.conf DEFAULT share_dhcp_address True
openstack-config --set /etc/nova/nova.conf DEFAULT force_dhcp_release True
openstack-config --set /etc/nova/nova.conf DEFAULT flat_network_bridge br100
openstack-config --set /etc/nova/nova.conf DEFAULT flat_interface eth1
openstack-config --set /etc/nova/nova.conf DEFAULT public_interface eth1

echo "Modify NOVA configuration files successfully" >> /tmp/openstack_c.zea

service ntpd stop
ntpdate $MASTERIP
if [ $? -ne 0 ];then
  echo -e "Ntpdate failed" >> /tmp/openstack_c.zea
else
  echo -e "Ntpdate successfully" >> /tmp/openstack_c.zea
fi
service ntpd start
