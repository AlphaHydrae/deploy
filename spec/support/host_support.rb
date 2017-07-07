module HostSupport
  def deploy_bin
    if ENV['TRAVIS']
      file = File.join ENV['TRAVIS_BUILD_DIR'], 'bin', 'deploy'
      raise "Expected deploy script to be at #{file} in a Travis environment" unless File.exist? file
      file
    elsif File.exist? '/vagrant'
      '/vagrant/bin/deploy'
    else
      raise "Unsupported environment"
    end
  end

  def deployer_user
    @@deployer_user ||= `echo -n $USER`
  end

  def server_user
    @@server_user ||= deployer_user
  end

  def uid_to_name uid
    @@user_names ||= {}
    @@user_names[uid] ||= Etc.getpwuid(uid).name
  end

  def gid_to_name gid
    @@group_names ||= {}
    @@group_names[gid] ||= Etc.getgrgid(gid).name
  end
end
