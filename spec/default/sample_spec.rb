require 'etc'
require 'fileutils'
require 'spec_helper'
require 'shellwords'
require 'tmpdir'

describe :setup do
  let(:deployer_user){ 'vagrant' }
  let(:deploy_user){ 'deploy' }

  around :each do |example|
    Dir.mktmpdir do |deployer_tmp|
      Dir.mktmpdir do |deploy_tmp|
        FileUtils.chown deployer_user, deployer_user, deployer_tmp
        FileUtils.chown deploy_user, deploy_user, deploy_tmp
        @deployer_tmp = deployer_tmp
        @deploy_tmp = deploy_tmp
        example.run
      end
    end
  end

  it "should work" do
    config_file = deploy_config! <<-CONFIG
[main]
user #{deploy_user}
host localhost
port 22
repo file://#{@deploy_tmp}/src
path #{@deploy_tmp}/deploy
rev master
    CONFIG

    puts File.read(config_file)

    Process.uid = Etc.getpwnam(deploy_user).uid
    raise 'bug' unless system "mkdir -p #{@deploy_tmp}/deploy"
    Dir.chdir @deploy_tmp
    raise 'bug' unless system 'mkdir src && cd src && git init'
    puts `ls -la #{@deploy_tmp}`

    Process.uid = Etc.getpwnam(deployer_user).uid
    Dir.chdir @deployer_tmp
    deploy :main, :setup
  end

  def deploy_config! config
    config_file = File.join @deployer_tmp, 'deploy.conf'
    File.open(config_file, 'w'){ |f| f.write config.to_s }
    FileUtils.chown deployer_user, deployer_user, config_file
    config_file
  end

  def deploy *args, &block
    options = args.last.kind_of?(Hash) ? args.pop : {}
    system args.unshift('/vagrant/bin/deploy').collect(&:to_s).join(' ')
  end

  def repo path
    
  end
=begin
  def self.options
    @options ||= deploy_options
  end

  def options
    self.class.options
  end

  def config
    unless @config
      @config = <<-CONFIG
[main]
user root
host #{options[:host_name]}
port #{options[:port]}
repo file:///vagrant
path #{options[:path]}
ref master
      CONFIG
    end

    @config
  end

  before :all do
    deploy config, :main, :setup
  end

  describe file("#{options[:path]}/releases") do
    it{ should be_directory }
    it{ should be_mode(755) }
    it{ should be_owned_by('root') }
    it{ should be_grouped_into('root') }
  end

  describe file("#{options[:path]}/repo") do
    it{ should be_directory }
    it{ should be_mode(755) }
    it{ should be_owned_by('root') }
    it{ should be_grouped_into('root') }
  end

  describe file("#{options[:path]}/repo/HEAD") do
    it{ should be_file }
  end

  describe file("#{options[:path]}/tmp") do
    it{ should be_directory }
    it{ should be_mode(755) }
    it{ should be_owned_by('root') }
    it{ should be_grouped_into('root') }
  end
=end
end
