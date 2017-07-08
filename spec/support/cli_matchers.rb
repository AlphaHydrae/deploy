require 'diffy'
require 'paint'

class ExpectedOutputBuilder
  def initialize &block
    @stdout = []
    @stderr = []
    instance_eval &block if block
  end

  def step description
    line
    line "  ○ #{description}"
  end

  def hook name
    step "hook #{name}"
  end

  def command command
    line "    #{command}"
  end

  def message message
    line "    #{message}"
  end

  def line contents = ''
    @stdout << contents
  end

  def error message
    stderr "  #{message}"
  end

  def stderr contents = ''
    @stderr << contents
  end

  def matches? stdout:, stderr:
    stdout_matches?(stdout) && stderr_matches?(stderr)
  end

  def stdout_matches? actual
    normalized = Paint.unpaint(actual).chomp
    expected = @stdout.join "\n"
    normalized == expected || (normalized.strip.empty? && expected.strip.empty?)
  end

  def stderr_matches? actual
    Paint.unpaint(actual).chomp == @stderr.join("\n")
  end

  def failure_message stdout:, stderr:
    messages = []

    unless stdout_matches? stdout
      messages << "expected that stdout #{stdout.inspect} would match expected output, but it differs:\n"
      messages << Diffy::Diff.new(stdout, @stdout.join("\n"))
    end

    unless stderr_matches? stderr
      messages << "expected that stderr #{stderr.inspect} would match expected output, but it differs:\n"
      messages << Diffy::Diff.new(stderr, @stderr.join("\n"))
    end

    messages.join "\n"
  end
end

RSpec::Matchers.define :exit_with do |expected|
  match do |actual|
    actual.status.exitstatus == expected
  end

  failure_message do |actual|
    "expected that command #{actual.command.inspect} would exit with status #{expected} but it exited with status #{actual.status.exitstatus}\n\nSTDOUT\n#{actual.stdout}\nSTDERR\n\n#{actual.stderr}\n"
  end
end

RSpec::Matchers.define :print do |expected|
  match do |actual|
    raise "The print matcher must be given a block" unless block_arg
    @matcher = ExpectedOutputBuilder.new &block_arg
    @matcher.matches? stdout: actual.stdout, stderr: actual.stderr
  end

  failure_message do |actual|
    @matcher.failure_message stdout: actual.stdout, stderr: actual.stderr
  end
end

RSpec::Matchers.define :print_error do |expected|
  match do |actual|
    block = block_arg || Proc.new{ error expected }
    @matcher = ExpectedOutputBuilder.new &block
    @matcher.matches? stdout: actual.stdout, stderr: actual.stderr
  end

  failure_message do |actual|
    @matcher.failure_message stdout: actual.stdout, stderr: actual.stderr
  end
end
