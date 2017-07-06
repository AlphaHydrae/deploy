module DeploySupport
  def deploy_config! config, name: 'deploy.conf', dir: @deployer_tmp
    raise "A directory is required (@deployer_tmp or explicit)" unless dir
    config_file = File.join @deployer_tmp, name
    File.open(config_file, 'w'){ |f| f.write config.to_s }
    config_file
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
end
