require 'open3'
require 'ostruct'

module CliSupport
  def deploy *args
    options = args.last.kind_of?(Hash) ? args.pop : {}
    command = args.unshift(deploy_bin).collect{ |arg| Shellwords.escape arg.to_s }.join(' ')
    run command: command, cwd: options[:cwd]
  end

  def run command:, cwd:
    stdout, stderr, status = nil, nil, nil

    Dir.chdir cwd do
      stdout, stderr, status = Open3.capture3 command
    end

    OpenStruct.new stdout: stdout, stderr: stderr, status: status
  end
end
