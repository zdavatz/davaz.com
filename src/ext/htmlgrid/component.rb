require 'htmlgrid/component'

module HtmlGrid
  class Component
    def dojo_props(args)
      args.map { |k, v|
        v = "\"#{escape(v)}\"" if v.is_a?(String)
        v = "[#{v.map { |s| "\"#{escape(s.to_s)}\""}.join(',')}]" if v.is_a?(Array)
        "#{k}:#{v}"
      }.join(',')
    end

    private

    def escape(v)
      v = v.gsub(',', '<comma/>').gsub(/\r?\n/, '<br/>')
      v = v.gsub(/\&quot;|"/, '')
      CGI::escapeHTML(v)
    end
  end
end
