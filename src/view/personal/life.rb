#!/usr/bin/env ruby
# View::Personal::Life -- davaz.com -- 27.09.2005 -- mhuggler@ywesee.com

require 'view/publictemplate'
require 'view/list'
require 'view/textblock'
require 'view/works/oneliner'
require 'view/slideshow'
require 'view/ticker'
require 'htmlgrid/divcomposite'
require 'htmlgrid/link'
require 'htmlgrid/ullist'

module DAVAZ
	module View
		module Personal
class LifeList < HtmlGrid::UlList
	CSS_ID = 'biography'
	COMPONENTS = {
		[0,0]	=>	View::TitleTextBlock,
	}
=begin
	OFFSET_STEP = [0,2]
	DEFAULT_CLASS = HtmlGrid::Value
	COMPONENTS = {
		[0,0]	=>	:date,
		[0,1]	=>	:text,
	}
	CSS_MAP = {
		[0,0]	=>	'title',
		[0,1]	=>	'text',
	}
	def date(model)
		link = HtmlGrid::Link.new("#{model.title}", model, @session)
		link.value = model.title
		link
	end
	def text(model)
		View::TextLine.new('text_line', model, @session, self)
	end
=end
end
class LifeTimePeriods < View::Composite
	CSS_ID = 'life-time-periods'
	COMPONENTS = {
		[0,0]	=>	:early_years,
		[1,0]	=>	:time_of_change,
		[2,0]	=>	:private_life,
		[3,0]	=>	:change_of_times,
	}
	COMPONENT_CSS_MAP = {
		[0,0,4]	=> 'life-times'
	}
	def early_years(model)
		link = HtmlGrid::Link.new(:early_years, model, @session)
		link.href = "#1946"
		link.css_class = 'no-decoration'
		link.value = @lookandfeel.lookup(:early_years) 
		link
	end
	def time_of_change(model)
		link = HtmlGrid::Link.new(:time_of_change, model, @session)
		link.href = "#1965"
		link.css_class = 'no-decoration'
		link.value = @lookandfeel.lookup(:time_of_change) 
		link
	end
	def private_life(model)
		link = HtmlGrid::Link.new(:private_life, model, @session)
		link.href = "#1975"
		link.css_class = 'no-decoration'
		link.value = @lookandfeel.lookup(:private_life) 
		link
	end
	def change_of_times(model)
		link = HtmlGrid::Link.new(:change_of_times, model, @session)
		link.href = "#1989"
		link.css_class = 'no-decoration'
		link.value = @lookandfeel.lookup(:change_of_times) 
		link
	end
end
class LifeTranslations < HtmlGrid::DivComposite
	CSS_ID = 'life-translations'
	COMPONENTS = {
		[0,0]	=>	:english,
		[1,0]	=>	'pipe_divider',
		[2,0]	=>	:chinese,
		[3,0]	=>	'pipe_divider',
		[4,0]	=>	:hungarian,
		[5,0]	=>	'pipe_divider',
		[6,0]	=>	:russian,
	}
	def english(model)
		link = HtmlGrid::Link.new(:english, model, @session, self)
		link.value = @lookandfeel.lookup(:english)
		args = { :lang	=>	'english' }
		link.href = @lookandfeel.event_url(:personal, :life, args) 
		link.css_class = 'no-decoration'
		link
	end
	def chinese(model)
		link = HtmlGrid::Link.new(:chinese, model, @session, self)
		link.value = @lookandfeel.lookup(:chinese)
		args = { :lang	=>	'chinese' }
		link.href = @lookandfeel.event_url(:personal, :life, args) 
		link.css_class = 'no-decoration'
		link
	end
	def hungarian(model)
		link = HtmlGrid::Link.new(:hungarian, model, @session, self)
		link.value = @lookandfeel.lookup(:hungarian)
		args = { :lang	=>	'hungarian' }
		link.href = @lookandfeel.event_url(:personal, :life, args) 
		link.css_class = 'no-decoration'
		link
	end
	def russian(model)
		link = HtmlGrid::Link.new(:russian, model, @session, self)
		link.value = @lookandfeel.lookup(:russian)
		link.href = @lookandfeel.resource(:cv_russian)
		link.css_class = 'no-decoration'
		link
	end
end
class LifeComposite < HtmlGrid::DivComposite
	CSS_CLASS = 'inner-content'
	COMPONENTS = {
		[0,0]	=>	:india_ticker_link,
		[0,1]	=>	:slideshow,
		[0,2]	=>	:oneliner,
		[0,3]	=>	LifeTimePeriods,
		[1,3]	=>	LifeTranslations,
		[2,3]	=>	LifeList,
	}
	def slideshow(model)
		model = @session.app.load_slideshow('life')
		View::Slideshow.new(model, @session, self)
	end
	def oneliner(model)
		model = @session.app.load_oneliner('hislife')
		View::Works::OneLiner.new(model, @session, self)
	end
	def india_ticker_link(model)
		link = HtmlGrid::Link.new(:india_ticker_link, model, @session, self)
		link.href = "javascript:void(0)"
		link.attributes['onclick']	= 'toggleTicker();' 
		link.value = @lookandfeel.lookup(:india_ticker_link)
		div = HtmlGrid::Div.new(model, @session, self)
		div.css_id = 'ticker-link'
		div.value = link
		div	
	end
end
class Life < View::PersonalPublicTemplate
	CONTENT = View::Personal::LifeComposite
	TICKER = View::TickerContainer
	SLIDESHOW_NAME = 'passage_through_india'
end
		end
	end
end
