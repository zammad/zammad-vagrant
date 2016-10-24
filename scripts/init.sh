cp /tmp/elasticsearch.repo /etc/yum.repos.d/elasticsearch.repo
cp /tmp/zammad.repo /etc/yum.repos.d/zammad.repo
cp /tmp/nginx.repo /etc/yum.repos.d/nginx.repo

rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
rpm --import https://rpm.packager.io/key

# TODO: Install dependencies - should get removed as far as possible when RPM is complete
yum -y install epel-release
yum -y install postgresql postgresql-devel postgresql-server postfix elasticsearch java cronie nginx zammad



postgresql-setup initdb
echo 'max_connections = 200' >> /var/lib/pgsql/data/postgresql.conf
echo 'shared_buffers = 2GB' >> /var/lib/pgsql/data/postgresql.conf
echo 'temp_buffers = 1GB' >> /var/lib/pgsql/data/postgresql.conf
echo 'work_mem = 6MB' >> /var/lib/pgsql/data/postgresql.conf
echo 'max_stack_depth = 2MB' >> /var/lib/pgsql/data/postgresql.conf
postgresql-setup initdb
systemctl start postgresql.service
systemctl enable postgresql.service
sudo -u postgres createuser -s zammad

rm -rf /etc/nginx/conf.d/*
sed -i.bak '/server_name\syour\.domain\.org;/d' /opt/zammad/contrib/nginx/sites-enabled/zammad.conf
cp /opt/zammad/contrib/nginx/sites-enabled/zammad.conf /etc/nginx/conf.d/


cd /usr/share/elasticsearch
bin/plugin -install elasticsearch/elasticsearch-mapper-attachments/2.5.0

systemctl start elasticsearch.service
systemctl enable elasticsearch.service

systemctl start postfix.service
systemctl enable postfix.service

chown -R zammad:zammad /opt/zammad
chmod 755 /tmp/zammad.sh
chown zammad:zammad /tmp/zammad.sh
su - zammad -c '/tmp/zammad.sh'

# scheduler
zammad run worker start &

# websockets
zammad run websocket start &

# puma
# zammad run web start &
# TODO: fails with: /opt/zammad/vendor/bundle/ruby/2.3.0/gems/activesupport-4.2.7.1/lib/active_support/dependencies.rb:274:in `require': cannot load such file -- rack/handler/start (LoadError)

# cu @ SELinux
setsebool httpd_can_network_connect on -P

systemctl start nginx.service
systemctl enable nginx.service
