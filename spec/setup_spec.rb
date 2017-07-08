require 'fileutils'
require 'git'
require 'spec_helper'

describe :setup do
  let(:config_file_user){ server_user }
  let(:config_file_host){ :localhost }
  let(:config_file_port){ 22 }
  let(:config_file_repo){ "file://#{@server_tmp}/repo" }
  let(:config_file_path){ "#{@server_tmp}/deploy" }
  let(:config_file_rev){ 'master' }
  let(:deploy_dir){ join @server_tmp, :deploy }
  let!(:deploy_repo){ generate_repo join(@server_tmp, :repo) }

  before :each do
    FileUtils.mkdir_p deploy_dir
  end

  it "should set up the correct directory structure and clone the repository" do
    deploy_config! <<-CONFIG
[main]
user #{config_file_user}
host #{config_file_host}
port #{config_file_port}
repo #{config_file_repo}
path #{config_file_path}
rev #{config_file_rev}
    CONFIG

    result = deploy :main, :setup

    expect(result.status).to be_success
    expect_setup deploy_dir, source_repo: deploy_repo
  end

  it "should work with a minimal config file" do
    deploy_config! <<-CONFIG
[main]
host #{config_file_host}
repo #{config_file_repo}
path #{config_file_path}
    CONFIG

    result = deploy :main, :setup

    expect(result.status).to be_success
    expect_setup deploy_dir, source_repo: deploy_repo
  end

  it "should not work without configuration" do
    result = deploy :main, :setup

    expect(result.status.exitstatus).to be(1)
    expect(deploy_dir).to be_directory.umask(:process).empty
  end

  it "should not work with no host configured" do
    deploy_config! <<-CONFIG
[main]
repo #{config_file_repo}
path #{config_file_path}
    CONFIG

    result = deploy :main, :setup

    expect(result.status.exitstatus).to be(1)
    expect(deploy_dir).to be_directory.umask(:process).empty
  end

  it "should not work with no repo configured" do
    deploy_config! <<-CONFIG
[main]
host #{config_file_host}
path #{config_file_path}
    CONFIG

    result = deploy :main, :setup

    expect(result.status.exitstatus).to be(1)
    expect(deploy_dir).to be_directory.umask(:process).contents('releases', 'tmp')
    expect(join(deploy_dir, 'releases')).to be_directory.empty
    expect(join(deploy_dir, 'tmp')).to be_directory.empty
  end

  it "should not work with no path configured" do
    deploy_config! <<-CONFIG
[main]
host #{config_file_host}
repo #{config_file_repo}
    CONFIG

    result = deploy :main, :setup

    expect(result.status.exitstatus).to be(1)
    expect(deploy_dir).to be_directory.umask(:process).empty
  end

  def expect_setup path, source_repo:
    expect(path).to be_directory.umask(:process).contents('releases', 'repo', 'tmp')
    expect(join(path, 'releases')).to be_directory.empty
    expect(join(path, 'tmp')).to be_directory.empty
    expect_git_repo path: join(path, 'repo'), source_repo: source_repo
  end

  def expect_git_repo path:, source_repo:, owner: nil, group: nil
    expect(path).to be_directory.owner(owner).group(group)
    expect(join(path, 'HEAD')).to be_file.owner(owner).group(group)
    expect(Git.bare(path).log.to_a.collect(&:sha)).to eq(source_repo.log.to_a.collect(&:sha))
  end
end
