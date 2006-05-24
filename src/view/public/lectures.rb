#!/usr/bin/env ruby
# View::Public::Lectures -- davaz.com -- 28.09.2005 -- mhuggler@ywesee.com

require 'view/publictemplate'
require 'view/textblock'
require 'htmlgrid/divcomposite'
require 'htmlgrid/divlist'

module DAVAZ
	module View
		module Public
class LecturesList < HtmlGrid::DivList
	CSS_CLASS = 'lectures'
	COMPONENTS = {
		[0,0]	=>	View::LectureTextBlock,
	}
end
class LecturesTitle < HtmlGrid::Div
	CSS_CLASS = 'table-title'
	def init
		super
		span = HtmlGrid::Span.new(model, @session, self)
		span.css_class = 'table-title'
		span.value = @lookandfeel.lookup(:lectures)
		@value = span
	end
end
class LecturesComposite < HtmlGrid::DivComposite
	CSS_CLASS = 'content'
	COMPONENTS = {
		[0,0]	=>	LecturesTitle,
		[1,0]	=>	LecturesList,	
	}
end
class Lectures < View::LecturesPublicTemplate
	CONTENT = View::Public::LecturesComposite 
end
		end
	end
end
