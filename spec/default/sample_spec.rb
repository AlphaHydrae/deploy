require 'spec_helper'

describe :setup do
  def self.options
    @options ||= deploy_options
  end

  def options
    self.class.options
  end

  def config
    unless @config
      @config = <<-CONFIG
[main]
user root
host #{options[:host_name]}
port #{options[:port]}
repo file:///vagrant
path #{options[:path]}
ref master
      CONFIG
    end

    @config
  end

  before :all do
    deploy config, :main, :setup
  end

  describe file("#{options[:path]}/releases") do
    it{ should be_directory }
    it{ should be_mode(755) }
    it{ should be_owned_by('root') }
    it{ should be_grouped_into('root') }
  end

  describe file("#{options[:path]}/repo") do
    it{ should be_directory }
    it{ should be_mode(755) }
    it{ should be_owned_by('root') }
    it{ should be_grouped_into('root') }
  end

  describe file("#{options[:path]}/repo/HEAD") do
    it{ should be_file }
  end

  describe file("#{options[:path]}/tmp") do
    it{ should be_directory }
    it{ should be_mode(755) }
    it{ should be_owned_by('root') }
    it{ should be_grouped_into('root') }
  end
end
