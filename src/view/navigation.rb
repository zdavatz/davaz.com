#!/usr/bin/env ruby
# View::TopNavigation -- davaz.com -- 19.07.2005 -- mhuggler@ywesee.com

require 'htmlgrid/divcomposite'
require 'htmlgrid/div'
require 'htmlgrid/divcomposite'
require 'view/maillink'
require 'htmlgrid/span'
require 'htmlgrid/ulcomposite'
require 'htmlgrid/spancomposite'
require 'view/composite'

module DAVAZ
	module View
		class NavigationComposite < HtmlGrid::SpanComposite
			COMPONENTS = {}
			CSS_CLASS = 'navigation'
			NAV_LINK_CSS = 'navigation'
			NAV_METHOD = :navigation
			SYMBOL_MAP = {
				:pipe_divider	=>	HtmlGrid::Text,
			}
			def init
				build_navigation()
				super
			end
			def build_navigation
				@link_idx = 0
				@zone_links = @lookandfeel.send(self::class::NAV_METHOD)
				@zone_links.each_with_index { |ary, idx| 
					pos = [idx*2,0]
					components.store(pos, :navigation_link)
					components.store([idx*2-1,0], 'pipe_divider') if idx > 0
				}
			end
			def navigation_link(model)
				zone, event = *(@zone_links.at(@link_idx))
				@link_idx += 1
				link = HtmlGrid::Link.new(event, model, @session, self)
				link.href = @lookandfeel.event_url(zone, event)
				link.css_class = self::class::CSS_CLASS 
				link
			end
			def email_link(model) 
				link = DAVAZ::View::MailLink.new(:contact_email, model, @session, self)
				link.mailto = @lookandfeel.lookup(:email_juerg)
				link.css_class = 'communication-link'
				link
			end
		end
		module TopNavigationModule
			class Composite < View::NavigationComposite 
				CSS_CLASS = "top-navigation"
				NAV_METHOD = :top_navigation
			end
		end
		class InitTopNavigation < HtmlGrid::DivComposite 
			CSS_CLASS = "top-navigation"
			COMPONENTS = {
				[0,0]	=>	TopNavigationModule::Composite,
			}
		end
		class TopNavigation < View::NavigationComposite 
			CSS_CLASS = "top-navigation"
			NAV_METHOD = :top_navigation
		end
		class FootNavigation < HtmlGrid::SpanComposite
			CSS_CLASS = 'foot-navigation'
			COMPONENTS = {
				0	=>	:guestbook,
				1	=>	'pipe_divider',
				2	=>	:shop,
				3	=>	'pipe_divider',
				4	=>	:email_link,
				5	=>	'pipe_divider',
				6	=>	:news,
				7	=>	'pipe_divider',
				8	=>	:links,
				9	=>	'pipe_divider',
				10	=>	:home,
			}
			def email_link(model) 
				link = DAVAZ::View::MailLink.new(:contact_email, model, @session, self)
				link.mailto = @lookandfeel.lookup(:email_juerg)
				link.css_class = 'foot-navigation'
				link
			end
			def home(model)
				link = HtmlGrid::Link.new(:home, model, @session, self)
				link.href = @lookandfeel.event_url(:personal, :home)
				link.css_class = 'foot-navigation'
				link
			end
			def guestbook(model)
				link = HtmlGrid::Link.new(:guestbook, model, @session, self)
				link.href = @lookandfeel.event_url(:communication, :guestbook)
				link.css_class = 'foot-navigation'
				link
			end
			def links(model)
				link = HtmlGrid::Link.new(:links, model, @session, self)
				link.href = @lookandfeel.event_url(:communication, :links)
				link.css_class = 'foot-navigation'
				link
			end
			def news(model)
				link = HtmlGrid::Link.new(:news, model, @session, self)
				link.href = @lookandfeel.event_url(:communication, :news)
				link.css_class = 'foot-navigation'
				link
			end
			def shop(model)
				link = HtmlGrid::Link.new(:shop, model, @session, self)
				link.href = @lookandfeel.event_url(:communication, :shop)
				link.css_class = 'foot-navigation'
				link
			end
		end
		class LeftNavigation < HtmlGrid::UlComposite 
			CSS_ID = 'left-navigation'
			COMPONENTS = { }
			def init
				@evt = @session.event
				links = [
					:drawings, :paintings, :multiples, :movies, :photos,
					:design, :schnitzenthesen, :empty_link
				]
				@small_links = [ 
					:search, :articles, :lectures, :exhibitions
				]
				links.concat(@small_links).each_with_index { |key, idx|
					components.store(idx, key)
					css_id = key.to_s
					css_class = 'left-navigation'
					if(@evt == key)
						css_id << '-active'
					end
					if(@small_links.include?(key))
						css_class << '-small'
					end
					css_id_map.store(idx, css_id)
					css_map.store(idx, css_class)
				}
				super
			end
			def drawings(model)
				navigation_link(model, :works, :drawings)
			end
			def paintings(model)
				navigation_link(model, :works, :paintings)
			end
			def multiples(model)
				navigation_link(model, :works, :multiples)
			end
			def movies(model)
				navigation_link(model, :works, :movies)
			end
			def photos(model)
				navigation_link(model, :works, :photos)
			end
			def design(model)
				navigation_link(model, :works, :design)
			end
			def schnitzenthesen(model)
				navigation_link(model, :works, :schnitzenthesen)
			end
			def empty_link(model)
				''
			end
			def search(model)
				link = HtmlGrid::Link.new(:gallery_search, model, @session, self)
				link.href = @lookandfeel.event_url(:gallery, :search)
				css = 'small-lnavlink'
				if(@evt == :search)
					css << '-active'
				end
				link.css_class = css
				link.css_id = 'search'
				link.value = @lookandfeel.lookup(:gallery_search) 
				link
			end
			def articles(model)
				navigation_link(model, :public, :articles)
			end
			def lectures(model)
				navigation_link(model, :public, :lectures)
			end
			def exhibitions(model)
				navigation_link(model, :public, :exhibitions)
			end
			def navigation_link(model, zone, key)
				link = HtmlGrid::Link.new(key, model, @session, self)
				link.href = @lookandfeel.event_url(zone, key)
				css = if(@small_links.include?(key))
					'small-lnavlink'
				else
					'lnavlink'
				end
				if(@evt == key)
					css << '-active'
				end
				link.css_class = css
				link.css_id = key.to_s
				link.value = @lookandfeel.lookup(key) 
				link
			end
		end
	end
end
