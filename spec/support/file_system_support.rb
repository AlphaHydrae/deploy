module FileSystemSupport
  def join *args
    File.join *args.collect(&:to_s)
  end

  def process_umask
    @@process_umask ||= File.umask
  end

  def ssh_umask
    @@ssh_umask ||= `ssh $USER@localhost umask`.strip.to_i(8)
  end

  def umask_digit umask:, position:
    raise "Umask must be an integer" unless umask.kind_of? Integer
    raise "Unsupported umask position #{position}" unless position >= 0 && position <= 2
    umask.to_s(8).rjust(3, '0')[position, 1].to_i
  end

  def default_permissions type:, umask:, position:
    raise "Unsupported default mode type #{type.inspect}" unless %i(file directory).include? type
    default_umask = send "#{umask}_umask"

    case type
    when :directory
      7 - umask_digit(umask: default_umask, position: position)
    when :file
      6 - umask_digit(umask: default_umask, position: position)
    else
      raise "Unsupported file type #{type.inspect}"
    end
  end

  def default_mode type, umask: :ssh
    [
      default_permissions(type: type, umask: umask, position: 0),
      default_permissions(type: type, umask: umask, position: 1),
      default_permissions(type: type, umask: umask, position: 2)
    ].join('')
  end

  def normalize_mode mode
    raise "Mode must be an integer or string" unless mode.kind_of?(String) || mode.kind_of?(Integer)
    mode = mode.to_s 8 if mode.kind_of? Integer
    mode.split(//).last(3).join('').rjust(3, '0')
  end
end
