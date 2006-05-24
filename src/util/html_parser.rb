#!/usr/bin/env ruby
# HtmlParser -- oddb -- 06.10.2003 -- mhuggler@ywesee.com


require 'html-parser'
require 'formatter'

module DAVAZ 
	class NullWriter < ::NullWriter
		def new_fonthandler(fonthandler); end
		def new_linkhandler(linkhandler); end
		def new_tablehandler(tablehandler); end
		def new_paragraph(paragraph); end
		def send_image(src); end
		def send_meta(attributes); end
	end
	class BasicHtmlParser < SGMLParser
		TEXT_LENGTH = 600
		attr_reader :html
		def initialize
			super
			@text = ''
			@html = ''
		end
		def unknown_starttag(tag, attrs)
			unless(@done)
				@html << "<#{tag}>"
			end
		end
		def unknown_endtag(tag)
			unless(@done)
				@html << "</#{tag}>"
			end
		end
		def do_br(attrs)
		end
		def handle_data(data)
			unless(@done)
				text = data.gsub(/\s+/, ' ')
				@text << text 
				@html << text
				if(@text.size > TEXT_LENGTH)
					left = TEXT_LENGTH - @text.size
					if((idx = @html.rindex('>')) && (@text.size - idx) > left)
						left = @text.size - idx
					end
					pos = @html.index(/\s/, left) \
						|| @html.index(/\&/, left) || TEXT_LENGTH
					@html[pos..-1] = '...'
					while(tag = @stack.pop)
						unknown_endtag(tag)
					end
					@done = true
				end
			end
		end
		def unknown_charref(name)
			unless(@done)
				@text << "..." 
				@html << "&##{name};" 
			end
		end
		def unknown_entityref(name)
			unless(@done)
				@text << "..." 
				@html << "&#{name};" 
			end
		end
	end
	class HtmlFormatter < AbstractFormatter

	end
end
