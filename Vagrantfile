# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.box = 'centos/7'

  config.vm.network 'forwarded_port', guest: 80, host: 3000, protocol: 'tcp'

  config.vm.provider :virtualbox do |vb|
    vb.name   = 'Zammad'
    vb.memory = 2048
    vb.cpus   = 2
  end

  config.vm.provision 'file',
    source:      'repos/elasticsearch.repo',
    destination: '/tmp/elasticsearch.repo'

  config.vm.provision 'file',
    source:      'repos/zammad.repo',
    destination: '/tmp/zammad.repo'

  config.vm.provision 'file',
    source:      'scripts/zammad.sh',
    destination: '/tmp/zammad.sh'

  config.vm.provision 'file',
    source:      'scripts/zammad_env.sh',
    destination: '/tmp/zammad_env.sh'

  config.vm.provision 'shell',
    path: 'scripts/init.sh'
end
