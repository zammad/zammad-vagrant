cp /tmp/zammad_env.sh $HOME
chmod 755 $HOME/zammad_env.sh

echo 'source $HOME/zammad_env.sh' >> $HOME/.bash_profile

source $HOME/zammad_env.sh

cd /opt/zammad

rails r "Setting.set('es_url', 'http://localhost:9200')"
sleep 15
rake searchindex:rebuild

