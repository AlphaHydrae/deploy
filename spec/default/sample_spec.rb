require 'etc'
require 'fileutils'
require 'git'
require 'spec_helper'
require 'shellwords'
require 'tmpdir'

describe :setup do
  let(:deployer_user){ `echo -n $USER` }
  let(:server_user){ deployer_user }

  around :each do |example|
    Dir.mktmpdir do |deployer_tmp|
      Dir.mktmpdir do |server_tmp|
        @deployer_tmp = deployer_tmp
        @server_tmp = server_tmp
        example.run
      end
    end
  end

  it "should work" do
    config_file = deploy_config! <<-CONFIG
[main]
user #{server_user}
host localhost
port 22
repo file://#{@server_tmp}/src
path #{@server_tmp}/deploy
rev master
    CONFIG

    puts File.read(config_file)

    src_dir = File.join @server_tmp, 'src'
    deploy_dir = File.join @server_tmp, 'deploy'

    FileUtils.mkdir_p src_dir
    FileUtils.mkdir_p deploy_dir

    repo src_dir

    puts "@@@@@@@ deployer_tmp = #{@deployer_tmp}"
    puts "@@@@@@@ deployer_tmp entries = #{Dir.entries @deployer_tmp}"
    Dir.chdir @deployer_tmp
    deploy :main, :setup
  end

  def deploy_config! config
    config_file = File.join @deployer_tmp, 'deploy.conf'
    File.open(config_file, 'w'){ |f| f.write config.to_s }
    config_file
  end

  def deploy *args, &block
    options = args.last.kind_of?(Hash) ? args.pop : {}
    system args.unshift('/vagrant/bin/deploy').collect(&:to_s).join(' ')
  end

  def repo path
    g = Git.init path
    g.config 'user.name', 'John Doe'
    g.config 'user.email', 'jdoe@example.com'
    File.open(File.join(path, 'foo'), 'w'){ |f| f.write 'bar' }
    g.add 'foo'
    g.commit 'One file'
    g
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
