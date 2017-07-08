require 'paint'

RSpec::Matchers.define :print_nothing do
  match do |actual|
    actual.match /^\s*$/
  end

  failure_message do |actual|
    "expected that #{actual.inspect} would be blank"
  end
end

RSpec::Matchers.define :print_message do |expected|
  match do |actual|
    Paint.unpaint(actual.strip) == expected
  end

  failure_message do |actual|
    "expected that #{actual.inspect} would be message #{expected.inspect}"
  end
end
