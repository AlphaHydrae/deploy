%i(file_system_support host_support).each do |dep|
  require File.join(File.dirname(__FILE__), "#{dep}.rb")
end

class FileMatch
  include FileSystemSupport
  include HostSupport

  attr_reader :actual_type, :actual_mode, :actual_owner, :actual_group, :actual_contents,
              :type_matches, :mode_matches, :owner_matches, :group_matches, :contents_match
  attr_accessor :expected_type, :expected_mode, :expected_owner, :expected_group, :expected_contents

  def initialize path, type: nil, mode: nil, owner: nil, group: nil, contents: nil
    @path = path

    @expected_type = type.to_sym
    @expected_mode = normalize_mode(mode.kind_of?(Symbol) ? default_mode(mode) : mode)
    @expected_owner = (owner || server_user).to_sym
    @expected_group = (group || server_user).to_sym
    @expected_contents = contents ? contents.flatten : nil

    stat = File.stat path
    @actual_mode = normalize_mode stat.mode
    @actual_owner = uid_to_name(stat.uid).to_sym
    @actual_group = gid_to_name(stat.gid).to_sym
    @actual_contents = Dir.entries(path).reject{ |e| e.match /^\.+$/ } if stat.directory?

    @actual_type = if stat.file?
     :file
    elsif stat.directory?
      :directory
    else
      :other
    end

    %i(type mode owner group).each do |attr|
      instance_variable_set("@#{attr}_matches", instance_variable_get("@actual_#{attr}") == instance_variable_get("@expected_#{attr}"))
    end

    @contents_match = !@expected_contents || @actual_contents == @expected_contents
  end

  def matches?
    @type_matches && @mode_matches && @owner_matches && @group_matches && @contents_match
  end

  def failure_message

    messages = []
    messages << "it was of type #{@actual_type}" unless @type_matches
    messages << "it had mode #{@actual_mode}" unless @mode_matches
    messages << "it was owned by #{@actual_owner}:#{@actual_group}" unless @owner_matches && @group_matches
    messages << "but it contained #{@actual_contents && !@actual_contents.empty? ? @actual_contents.join(', ') : 'nothing'}" unless @contents_match
    message = messages.empty? ? '' : " but #{messages.join(' and ')}"

    contents_message = @expected_contents ? " containing #{@expected_contents && !@expected_contents.empty? ? @expected_contents.join(', ') : 'nothing'}" : ''

    "expected that #{@path} would be a #{@expected_type} with mode #{@expected_mode} owned by #{@expected_owner}:#{@expected_group}#{contents_message}#{message}"
  end
end

%i(file directory).each do |type|
  RSpec::Matchers.define "be_#{type}".to_sym do |mode: type|
    match do |actual|
      @match = FileMatch.new actual, type: type, mode: mode, owner: @owner, group: @group, contents: @contents
      @match.matches?
    end

    chain :owner do |owner|
      @owner = owner
    end

    chain :group do |group|
      @group = group
    end

    chain :contents do |*names|
      @contents = names
    end

    chain :empty do
      @contents = []
    end

    failure_message do |actual|
      @match.failure_message
    end
  end
end
