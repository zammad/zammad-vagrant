cp /tmp/elasticsearch.repo /etc/yum.repos.d/elasticsearch.repo
cp /tmp/zammad.repo /etc/yum.repos.d/zammad.repo

rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
rpm --import https://rpm.packager.io/key

# TODO: Install dependencies - should get removed as far as possible when RPM is complete
yum -y install epel-release
yum -y install mc postfix elasticsearch java cronie zammad 

cd /usr/share/elasticsearch && bin/elasticsearch-plugin install mapper-attachments

echo 'max_connections = 200' >> /var/lib/pgsql/data/postgresql.conf
echo 'shared_buffers = 2GB' >> /var/lib/pgsql/data/postgresql.conf
echo 'temp_buffers = 1GB' >> /var/lib/pgsql/data/postgresql.conf
echo 'work_mem = 6MB' >> /var/lib/pgsql/data/postgresql.conf
echo 'max_stack_depth = 2MB' >> /var/lib/pgsql/data/postgresql.conf

systemctl start elasticsearch.service
systemctl enable elasticsearch.service

systemctl start postfix.service
systemctl enable postfix.service

chown -R zammad:zammad /opt/zammad
chmod 755 /tmp/zammad.sh
chown zammad:zammad /tmp/zammad.sh
su - zammad -c '/tmp/zammad.sh'

# scheduler
zammad run worker &>> /opt/zammad/log/zammad.log &

# websockets
zammad run websocket &>> /opt/zammad/log/zammad.log &

zammad run web &>> /opt/zammad/log/zammad.log &

systemctl start nginx.service
systemctl enable nginx.service
