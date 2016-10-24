cp /tmp/zammad_env.sh $HOME
chmod 755 $HOME/zammad_env.sh

echo 'source $HOME/zammad_env.sh' >> $HOME/.bash_profile

source $HOME/zammad_env.sh

cd /opt/zammad

rake db:create
rake db:migrate
rake db:seed

rails r "Setting.set('es_url', 'http://localhost:9200')"
sleep 15
rake searchindex:rebuild

./vendor/bundle/ruby/2.3.0/bin/puma -e production -p 3000 &

sleep 10
