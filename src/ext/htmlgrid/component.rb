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
      v = v.gsub(/\&quot;|"/, '')
      v = CGI::escapeHTML(v)
      # Placeholders MUST come after CGI::escapeHTML — otherwise their `<`/`>`
      # get encoded and the consumer's /<comma[^>]*>/g regex misses them.
      v.gsub(',', '<comma/>').gsub(/\r?\n/, '<br/>')
    end
  end
end
