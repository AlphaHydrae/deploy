require 'fileutils'
require 'securerandom'

module DeploySupport
  def deploy_config! config, name: 'deploy.conf', dir: @deployer_tmp
    raise "A directory is required (@deployer_tmp or explicit)" unless dir
    config_file = File.join @deployer_tmp, name
    File.open(config_file, 'w'){ |f| f.write config.to_s }
    config_file
  end

  def generate_repo path
    FileUtils.mkdir_p path

    g = Git.init path
    g.config 'user.name', 'John Doe'
    g.config 'user.email', 'jdoe@example.com'

    2.times do
      name = SecureRandom.uuid
      File.open(File.join(path, name), 'w'){ |f| f.write SecureRandom.uuid }
      g.add name
      g.commit "Add #{name}"
    end

    g
  end
end
