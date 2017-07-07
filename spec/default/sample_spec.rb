require 'etc'
require 'fileutils'
require 'git'
require 'spec_helper'
require 'shellwords'
require 'tmpdir'

describe :setup do
  it "should work" do
    config_file = deploy_config! <<-CONFIG
[main]
user #{server_user}
host localhost
port 22
repo file://#{@server_tmp}/repo
path #{@server_tmp}/deploy
rev master
    CONFIG

    deploy_dir = join @server_tmp, :deploy
    FileUtils.mkdir_p deploy_dir

    repo = generate_repo join(@server_tmp, :repo)

    result = deploy :main, :setup, cwd: @deployer_tmp

    expect(result.status).to be_success
    expect_setup deploy_dir, source_repo: repo
  end

  def expect_setup path, source_repo:
    expect(join(path, 'releases')).to be_directory
    expect(join(path, 'tmp')).to be_directory
    expect_git_repo path: join(path, 'repo'), source_repo: source_repo
  end

  def expect_git_repo path:, source_repo:, owner: nil, group: nil
    expect(path).to be_directory.owner(owner).group(group)
    expect(join(path, 'HEAD')).to be_file.owner(owner).group(group)
    expect(Git.bare(path).log.to_a.collect(&:sha)).to eq(source_repo.log.to_a.collect(&:sha))
  end
end
