#!/usr/bin/env ruby
# ParseCVHtml -- davaz.com -- 19.05.2006 -- mhuggler@ywesee.com

require 'html-parser'
require 'formatter'

module ParseCVHtml
	class CVEntry
		attr_reader :year, :text
		def initialize(year)
			@year = year
			@text = ""
		end
		def add_text(text)
			@text << text
		end
	end
	class Writer < ::NullWriter
		attr_reader :cventries
		def initialize
			@cventries = []
		end
		def send_flowing_data(data)
			data.gsub!(' ', '')
			if(data.match(/^19[0-9][0-9]/))
				entry = CVEntry.new(data)
				@cventries.push(entry)
			elsif(data == '&#24180;' && (cventry = @cventries.last) \
						&& !/24180;$/.match(cventry.year))
				cventry.year << data
			elsif(cventry = @cventries.last)
				cventry.add_text(data)
			end
		end
		def extract_data
			@cventries.each { |entry| 
				puts "year: #{entry.year} und text: #{entry.text}"
			}
		end
	end
	class Formatter < AbstractFormatter
	end
	class Parser < HTMLParser
		def unknown_charref(name)
			handle_data("&##{name};")
		end
		def unknown_entityref(name)
			handle_data("&#{name};")
		end
	end
	class Parsing
		def initialize(file)
			@file = file
		end
		def start 
			writer = Writer.new()
			formatter = Formatter.new(writer)
			parser = Parser.new(formatter)
			path = File.expand_path("html/hislife/#{@file}.html", 
				File.dirname(__FILE__))
			html = File.read(path)
			parser.feed(html)
			#writer.extract_data
			writer.cventries
		end
	end
end

parsing = ParseCVHtml::Parsing.new('cv_chinese')
parsing.start
