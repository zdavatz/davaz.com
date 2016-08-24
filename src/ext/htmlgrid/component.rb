require 'htmlgrid/component'

module HtmlGrid
  class Component
    def dojo_props(args)
      args.map { |k, v|
        v = "'#{v}'" if v.is_a?(String)
        v = "[#{v.map { |s| "'#{s}'"}.join(',')}]" if v.is_a?(Array)
        "#{k}:#{v}"
      }.join(',')
    end
  end
end
