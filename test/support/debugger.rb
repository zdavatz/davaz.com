if defined?(DEBUGGER)
  DEBUGGER.split(',').map do |debugger|
    require debugger.downcase
  end
end
