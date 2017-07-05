# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu/xenial64'

  config.vm.provision 'shell', inline: <<-SHELL
    apt-get update
    apt-get install -y ruby
    gem install --no-ri --no-rdoc bundler
    cd /vagrant && bundle install
    /vagrant/spec/scripts/init.sh
  SHELL
end

# TODO: https://github.com/benoitbryon/xal/blob/master/.travis-ssh.sh
