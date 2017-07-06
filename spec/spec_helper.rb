require 'serverspec'

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each{ |f| require f }

set :backend, :exec

RSpec.configure do |config|
  config.include CliSupport
  config.include DeploySupport
  config.include FileSystemSupport
  config.include HostSupport

  config.add_setting :umask

  config.before :suite do
    RSpec.configuration.umask = File.umask
  end
end
