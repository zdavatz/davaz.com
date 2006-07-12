#!/usr/bin/env ruby
# View::TextBlock -- davaz.com -- 20.03.2006 -- mhuggler@ywesee.com

require 'uri'
require 'htmlgrid/namedcomponent'
require 'htmlgrid/span'
require 'htmlgrid/link'
require 'util/image_helper'

module DAVAZ 
	module View
		class TextBlock < HtmlGrid::Component
			def initialize(model, session, container)
				super
				@images = []
			end
			def add_hidden_divs(html, context)
				links = @model.links
				links.each { |link|
					div_content = ""
					if(link.artobjects.size > 1)
						link.artobjects.each { |aobject|
							artobject_id = aobject.artobject_id
							image = HtmlGrid::Image.new(artobject_id, \
								@model, @session, self)
							url = DAVAZ::Util::ImageHelper.image_path(artobject_id)
							image.set_attribute('src', url)
							div_content << image.to_html(context)
							if(aobject.text)
								span = HtmlGrid::Span.new(@model, @session, self)
								span.value = aobject.text
								div_content << span.to_html(context)
							end
						}
					end
					compose_hidden_div(html, context, link, div_content)
				}
				html
			end
			def add_image(context)
				artobject_id = @model.artobject_id
				if(Util::ImageHelper.has_image?(artobject_id))
					image = HtmlGrid::Image.new(artobject_id, @model, @session, self)
					url = Util::ImageHelper.image_path(artobject_id, 'large')
					image.set_attribute('src', url)
					image.css_id = @model.artobject_id
					#span = HtmlGrid::Span.new(@model, @session, self)
					#span.value = image.to_html(context)
					#span.css_id = @model.artobject_id
					#span.css_class = 'block-image'
					#span.dojo_tooltip = url
					#ttip_args = [ :artobject_id, @model.artobject_id  ]
					#url = @lookandfeel.event_url(:tooltip, :tooltip, ttip_args)
					#link = HtmlGrid::Link.new(:toolgip, @model, @session, self)
					#link.href = url
					#link.set_attribute('dojoType', 'tooltip')
					#link.set_attribute('connectId', @model.artobject_id)
					args = {
						'class'				=>	'block-image',
					}
					div = context.div(args) { image.to_html(context) }
				else
					""
				end
			end
			def add_links(txt, context)
				map = {}
				@model.links.each { |link|
					map.store(link.word, link)
				}
				txt.gsub(/(#{map.keys.join(')|(')})/) { |match|
					if(link = map[match])
						linkify(link, context) + "\n"
					end.to_s
				}
			end
			def author_to_html(context)
				if(@model.author.empty?)
					""
				else
					args = {
						'class'	=>	'block-author'
					}
					context.div(args) { add_links(@model.author, context) }
				end
			end
			def compose_hidden_div(html, context, link, div_content)
				args = { 
					'class' => 'hidden-div',
					'id'		=>	"#{link.link_id}-hidden-div",
				}
				html << context.div(args) { 
					hide_link(link, context) << 
					div_content <<	
					hide_link(link, context)
				}
			end
			def date_to_html(context)
				if(@model.date == '0000-00-00')
					""
				else
					args = {
						'class'	=>	'block-date'
					}
					context.div(args) { add_links(@model.date, context) }
				end
			end
			def hide_link(link, context)
				hide_link = HtmlGrid::Link.new(:hide_link, @model, 
					@session, self)
				hide_link.href = 'javascript:void(0)'
				span = HtmlGrid::Span.new(@model, @session, self)
				span.css_class = 'hide-hidden-div-link'
				span.value = @lookandfeel.lookup(:hide) 
				hide_link.value = span.to_html(context)
				script = "toggleHiddenDiv('#{link.link_id}-hidden-div')"
				hide_link.set_attribute('onclick', script)
				hide_link.to_html(context)
			end
			def linkify(link, context)
				if(link.artobjects.size == 1)
					artobject = link.artobjects.first
					if(artobject.is_url?)
						lnk = HtmlGrid::Link.new(link.word, @model, @session, self)
						lnk.href = artobject.url 
						lnk.value = link.word
						lnk.to_html(context)
					else
						@link_id ||= 0
						@link_id += 1
						args = [ :artobject_id, artobject.artobject_id  ]
						url = @lookandfeel.event_url(:tooltip, :tooltip, args)
						span = HtmlGrid::Span.new(@model, @session, self)
						span.value = link.word
						span.css_class = 'blue'
						span.css_id = [link.link_id, @link_id].join('_')
						span.dojo_tooltip = url 
						span.to_html(context)
					end
				elsif(link.artobjects.size > 1)
					lnk = HtmlGrid::Link.new(link.word, @model, @session, self)
					lnk.href = 'javascript:void(0)'
					lnk.value = link.word
					script = "toggleHiddenDiv('#{link.link_id}-hidden-div')"
					lnk.set_attribute('onclick', script)
					lnk.to_html(context)
				end
			end
			def text_to_html(context)
				if(@model.text.empty?)
					""
				else
					args = {
						'class'	=>	'block-text'
					}
					context.div(args) { add_links(@model.text, context) }
				end
			end
			def url_to_html(context)
				if(@model.url.empty?)
					""
				else
					args = {
						'class'	=>	'block-url'
					}
					link_args = {
						'href' =>	"http://#{@model.url}",
						'target' =>	'_blank',
					}
					context.div(args) { context.a(link_args) { @model.url } }
				end
			end
			def title_to_html(context)
				if(@model.title.empty?)
					""
				else
					title = @model.title
					args = {
						'name'	=> title.downcase.gsub(/\s+/,"")
					}
					link = context.a(args) {add_links(title, context)}
					args = {
						'class'	=>	'block-title'
					}
					context.div(args) { link }
				end
			end
			def to_html(context)
				html = title_to_html(context)
				html << url_to_html(context)
				html << date_to_html(context)
				html << author_to_html(context)
				html << add_image(context)
				html << text_to_html(context)
				add_hidden_divs(html, context)
			end
		end
		class AdminTextBlock < TextBlock 
			def add_edit_link(context)
				breadcrumbs = @session.update_breadcrumbs
				link = HtmlGrid::Link.new(:edit_link, @model, @session, self) 
				link.css_class = 'admin-action'
				link.value = @session.lookandfeel.lookup(:edit)
				args = [
					[ :artobject_id, @model.artobject_id ],
					[	:breadcrumbs, breadcrumbs ],
				]
				url = @lookandfeel.event_url(:admin, :edit, args) 
				link.href = url
				context.div({'class', link.css_class}) { link.to_html(context) }
			end
			def to_html(context)
				#html = add_edit_link(context)
				#html << super
				super
			end
		end
=begin
		class LinkTextBlock < View::TextBlock
			def link_to_html(context) 
				link = @model.title
				date = @model.date
				date_args = {
					'class'		=>	'link-title',
				}
				link_args = {
					'class'		=>	'link-title',
					'href'		=>	link,
					'target'	=>	'_blank',
				}
				div_link_args = { 'class'	=>	'link-title-link' }
				div_date_args = { 'class'	=>	'link-title-date' }
				args = { 'class'		=>	'link-title', }
				link = context.a(link_args) { link }
				date = context.span(date_args) { date }
				div_link = context.div(div_link_args) { link }
				div_date = context.div(div_date_args) { date }
				context.div(args) { [ div_link, div_date] }
			end
			def text_to_html(context)
				text = @model.text
				args = { 'class' => 'link-text' }
				context.div(args){ text }
			end
			def to_html(context)
				html = link_to_html(context) 
				html << text_to_html(context)
				add_hidden_divs(html, context)
			end
		end
		class TitleTextBlock < View::TextBlock
			def to_html(context)
				html = anchor_title_to_html(context)
				html << text_to_html(context)
				add_hidden_divs(html, context)
			end
		end
		class AdminTitleTextBlock < View::AdminTextBlock
			def to_html(context)
				html = anchor_title_to_html(context)
				html << text_to_html(context)
				add_hidden_divs(html, context)
			end
		end
		class LectureTextBlock < View::TextBlock
			def to_html(context)
				html = title_to_html(context)
				html << text_to_html(context)
				add_hidden_divs(html, context)
			end
		end
		class ExhibitionTextBlock < View::TextBlock
			def to_html(context)
				html = title_to_html(context)
				html << text_to_html(context)
				add_hidden_divs(html, context)
			end
		end
=end
	end
end
