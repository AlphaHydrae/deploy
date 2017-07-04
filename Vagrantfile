# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu/xenial64'

  config.vm.provision 'shell', inline: <<-SHELL
    authorized_key() {

      local home=$1
      local user=$2
      local key="$3"
      shift; shift; shift
      local message="$@"

      if ! grep -q "$key" $home/.ssh/authorized_keys; then
        umask 077
        mkdir -p $home/.ssh
        chown $user:$user $home/.ssh
        umask 066
        echo "$key" >> $home/.ssh/authorized_keys
        chown $user:$user $home/.ssh/authorized_keys
        echo "$message"
      fi
    }

    test_user() {
      local user=$1
      local home=$2
      local known_hosts=$3
      cat /etc/passwd|grep -q "^$user:" || { useradd -m $user && echo Created $user user; }
      test -n "$known_hosts" && ! test -f $home/.ssh/known_hosts && su - $user -c "mkdir -p $home/.ssh && chmod 700 $home/.ssh && ssh-keyscan -H localhost 2>/dev/null >> $home/.ssh/known_hosts"
    }

    generate_key() {
      local home=$1
      local user=$2
      test -f $home/.ssh/id_rsa || su - $user -c "ssh-keygen -t rsa -b 1024 -N '' -C $user -f $home/.ssh/id_rsa"
    }

    test_user deploy /home/deploy
    test_user vagrant /home/vagrant yes

    LOCAL_PUBLIC_KEY="#{File.read(File.expand_path('~/.ssh/id_rsa.pub')).strip}"
    authorized_key /root root "$LOCAL_PUBLIC_KEY" Local public key added to root user

    generate_key /home/vagrant vagrant
    authorized_key /home/deploy deploy "$(cat /home/vagrant/.ssh/id_rsa.pub|head -n 1)" Vagrant public key added to deploy user

    apt-get update
    apt-get install -y ruby

    gem install --no-ri --no-rdoc bundler
    cd /vagrant && bundle install
  SHELL
end

# TODO: https://github.com/benoitbryon/xal/blob/master/.travis-ssh.sh
