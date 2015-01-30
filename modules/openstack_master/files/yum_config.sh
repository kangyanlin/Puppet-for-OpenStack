#!/bin/bash

mv /etc/yum.repos.d/cobbler-config.repo /tmp/

yum install -y http://repos.fedorapeople.org/repos/openstack/openstack-icehouse/rdo-release-icehouse-4.noarch.rpm http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

sleep 0.2

yum update -y
