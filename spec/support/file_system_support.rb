module FileSystemSupport
  def join *args
    File.join *args.collect(&:to_s)
  end

  def umask
    RSpec.configuration.umask
  end

  def umask_digit i
    umask.to_s(8).rjust(3, '0')[i, 1].to_i
  end

  def default_permissions i, type
    raise "Unsupported umask position #{i}" unless i >= 0 && i <= 2

    case type
    when :directory
      7 - umask_digit(i)
    when :file
      6 - umask_digit(i)
    else
      raise "Unsupported file type #{type.inspect}"
    end
  end

  def default_mode type
    [ default_permissions(0, type), default_permissions(1, type), default_permissions(2, type) ].join('')
  end

  def normalize_mode mode
    raise "Mode must be an integer or string" unless mode.kind_of?(String) || mode.kind_of?(Integer)
    mode = mode.to_s 8 if mode.kind_of? Integer
    mode.split(//).last(3).join('').rjust(3, '0')
  end
end
