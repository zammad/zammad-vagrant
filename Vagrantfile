# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.box = 'centos/7'

  config.vm.network 'forwarded_port', guest: 3000, host: 3000, protocol: 'tcp'

  config.vm.provider :virtualbox do |vb|
    vb.name   = 'Zammad'
    vb.memory = 4096
    vb.cpus   = 2
  end

  config.vm.provision 'shell',
    path: 'zammad.sh', args: ENV['PACKAGER_REPO']

end
