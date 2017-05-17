# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu/xenial64'

  config.vm.provision 'shell', inline: <<-SHELL
    umask 077
    mkdir -p /root/.ssh
    umask 066
    echo "#{File.read(File.expand_path('~/.ssh/id_rsa.pub'))}" >> /root/.ssh/authorized_keys
  SHELL
end
