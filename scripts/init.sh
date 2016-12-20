#!/bin/bash

if [ -z $1 ]; then
    PACKAGER_REPO="develop"
else
    PACKAGER_REPO="$1"
fi

echo "[zammad]
name=Repository for zammad/zammad application.
baseurl=https://rpm.packager.io/gh/zammad/zammad/centos7/${PACKAGER_REPO}
enabled=1" | tee /etc/yum.repos.d/zammad.repo

echo "[elasticsearch-5.x]
name=Elasticsearch repository for 5.x packages
baseurl=https://artifacts.elastic.co/packages/5.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md" | tee /etc/yum.repos.d/elasticsearch.repo

rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
rpm --import https://rpm.packager.io/key

yum -y install epel-release
yum -y install mc postfix elasticsearch java cronie zammad

sysctl -w vm.max_map_count=262144
cd /usr/share/elasticsearch && yes | bin/elasticsearch-plugin install ingest-attachment

echo 'max_connections = 200' >> /var/lib/pgsql/data/postgresql.conf
echo 'shared_buffers = 2GB' >> /var/lib/pgsql/data/postgresql.conf
echo 'temp_buffers = 1GB' >> /var/lib/pgsql/data/postgresql.conf
echo 'work_mem = 6MB' >> /var/lib/pgsql/data/postgresql.conf
echo 'max_stack_depth = 2MB' >> /var/lib/pgsql/data/postgresql.conf

systemctl start elasticsearch.service
systemctl enable elasticsearch.service

systemctl start postfix.service
systemctl enable postfix.service

zammad scale web=1 websocket=1 worker=1
systemctl enable zammad
systemctl start zammad

zammad run rails r "Setting.set('es_url', 'http://127.0.0.1:9200')"
zammad run rake searchindex:rebuild

systemctl start nginx.service
systemctl enable nginx.service
