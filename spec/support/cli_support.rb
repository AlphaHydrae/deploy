require 'open3'
require 'ostruct'
require 'shellwords'

module CliSupport
  def deploy *args
    options = args.last.kind_of?(Hash) ? args.pop : {}
    command = args.unshift(deploy_bin).collect{ |arg| Shellwords.escape arg.to_s }.join(' ')
    run command: command, cwd: options[:cwd] || @deployer_tmp
  end

  def run command:, cwd:
    stdout, stderr, status = nil, nil, nil

    Dir.chdir cwd do
      stdout, stderr, status = Open3.capture3 command
    end

    OpenStruct.new command: command, stdout: stdout, stderr: stderr, status: status
  end
end
