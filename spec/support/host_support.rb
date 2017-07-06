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
    @deployer_user ||= `echo -n $USER`
  end

  def server_user
    @server_user ||= deployer_user
  end
end
