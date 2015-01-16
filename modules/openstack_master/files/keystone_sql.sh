#!/bin/bash

# create keystone database & grant

/usr/bin/mysql -uroot -pzeastion <<EOF
create database lzydb;
grant all privileges on lzydb.* to 'lzy'@'localhost' identified by 'lzy';
grant all privileges on lzydb.* to 'lzy'@'%' identified by 'lzy';
grant all privileges on lzydb.* to 'lzy'@10.2.20.179 identified by 'lzy';
flush privileges;
EOF
