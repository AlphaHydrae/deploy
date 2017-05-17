require 'fileutils'
require 'net/ssh'
require 'securerandom'
require 'serverspec'
require 'shellwords'

set :backend, :ssh

if ENV['ASK_SUDO_PASSWORD']
  begin
    require 'highline/import'
  rescue LoadError
    fail "highline is not available. Try installing it."
  end
  set :sudo_password, ask("Enter sudo password: ") { |q| q.echo = false }
else
  set :sudo_password, ENV['SUDO_PASSWORD']
end

host = ENV['TARGET_HOST']

config = File.join 'tmp', "ssh-config-#{Time.now.utc.strftime("%Y-%m-%d")}"
FileUtils.mkdir_p File.dirname(config)

File.open(config, 'w'){ |f| f.write `vagrant ssh-config #{host}` } unless File.exist? config

options = Net::SSH::Config.for(host, [ config ])

options[:user] ||= Etc.getlogin

set :host,        options[:host_name] || host
set :ssh_options, options

# Disable sudo
# set :disable_sudo, true

# Set environment variables
# set :env, :LANG => 'C', :LC_MESSAGES => 'C'

# Set PATH
# set :path, '/sbin:/usr/local/sbin:$PATH'

SSH_CONFIG = options

def deploy_options
  id = SecureRandom.uuid

  begin
    ssh = Net::SSH.start(SSH_CONFIG[:host_name], 'root', port: SSH_CONFIG[:port])
    res = ssh.exec!("mkdir -p /tmp/deploy/#{id}")
    ssh.close

    {
      id: id,
      path: "/tmp/deploy/#{id}",
      host: SSH_CONFIG[:host_name],
      port: SSH_CONFIG[:port],
      user: 'root'
    }
  rescue StandardError => e
    raise "Unable to connect to #{SSH_CONFIG[:host_name]} as root: #{e.message}"
  end
end

def deploy config, *args
  File.open('deploy.conf', 'w'){ |f| f.write config }
  output = `#{args.collect{ |arg| Shellwords.escape arg.to_s }.unshift('./bin/deploy').join(' ').to_s}`
  raise output if $? != 0
end
