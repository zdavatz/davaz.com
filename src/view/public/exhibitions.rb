#!/usr/bin/env ruby
# View::Public::Exhibitions -- davaz.com -- 28.09.2005 -- mhuggler@ywesee.com

require 'view/publictemplate'
require 'htmlgrid/divcomposite'
require 'htmlgrid/divlist'

module DAVAZ
	module View
		module Public
class ExhibitionsList < HtmlGrid::DivList
	CSS_CLASS = 'exhibitions'
	COMPONENTS = {
		[0,0]	=>	View::TextBlock,
	}
end
class ExhibitionsTitle < HtmlGrid::Div
	CSS_CLASS = 'table-title'
	def init
		super
		span = HtmlGrid::Span.new(model, @session, self)
		span.css_class = 'table-title'
		span.value = @lookandfeel.lookup(:exhibitions)
		@value = span
	end
end
class ExhibitionsComposite < HtmlGrid::DivComposite
	CSS_CLASS = 'content'
	COMPONENTS = {
		[0,0]	=> ExhibitionsTitle,
		[1,0]	=> ExhibitionsList,	
	}
end
class Exhibitions < View::ExhibitionsPublicTemplate
	CONTENT = View::Public::ExhibitionsComposite 
end
		end
	end
end
