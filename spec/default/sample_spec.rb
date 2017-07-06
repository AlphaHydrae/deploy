require 'etc'
require 'fileutils'
require 'git'
require 'spec_helper'
require 'shellwords'
require 'tmpdir'

describe :setup do
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

    src_dir = File.join @server_tmp, 'src'
    deploy_dir = File.join @server_tmp, 'deploy'

    FileUtils.mkdir_p src_dir
    FileUtils.mkdir_p deploy_dir

    repo src_dir

    result = deploy :main, :setup, cwd: @deployer_tmp
    puts result.stdout

    expect(result.status).to be_success
    expect_setup deploy_dir
  end

  def expect_setup path
    expect_directory path: File.join(path, 'releases')
    expect_directory path: File.join(path, 'tmp')
    expect_git_repo path: File.join(path, 'repo')
  end

  def expect_git_repo path:, owner: server_user, group: server_user
    expect_directory path: path
    expect_file path: File.join(path, 'HEAD')
  end

  def expect_directory path:, mode: :directory, owner: server_user, group: server_user
    dir = file(path)
    expect(dir).to be_directory
    expect(dir).to be_mode(mode.kind_of?(Symbol) ? default_mode(mode) : mode)
    expect(dir).to be_owned_by(owner)
    expect(dir).to be_grouped_into(group)
  end

  def expect_file path:, mode: :file, owner: server_user, group: server_user
    f = file(path)
    expect(f).to be_file
    expect(f).to be_mode(mode.kind_of?(Symbol) ? default_mode(mode) : mode)
    expect(f).to be_owned_by(owner)
    expect(f).to be_grouped_into(group)
  end
end
