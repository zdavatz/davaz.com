#!/usr/bin/env ruby
# View::TextBlock -- davaz.com -- 20.03.2006 -- mhuggler@ywesee.com

require 'uri'
require 'htmlgrid/namedcomponent'
require 'htmlgrid/span'
require 'htmlgrid/link'

module DAVAZ 
	module View
		class TextBlock < HtmlGrid::Component
			def initialize(model, session, container)
				super
				@images = []
			end
			def anchor_title_to_html(context)
				title = @model.title
				args = {
					'name'	=> title.downcase.gsub(/\s+/,"")
				}
				link = context.a(args) {add_links(title, context)}
				args = {
					'class'	=>	'block-title'
				}
				context.h1(args) { link }
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
			def add_hidden_divs(html, context)
				links = @model.links
				links.each { |link|
					div_content = ""
					if(link.type == 'image')
						if(link.displayelements.size > 1)
							link.displayelements.each { |display|
								display_id = display.display_id
								image = HtmlGrid::Image.new(display_id, \
									@model, @session, self)
								url = @lookandfeel.upload_image_path(display_id)
								image.set_attribute('src', url)
								div_content << image.to_html(context)
							}
							compose_hidden_div(html, context, link, div_content)
						end
					elsif(link.type == 'text')
						display = link.displayelements.first
						div_content << title_to_html(context, display.title)
						div_content << author_to_html(context, display.author)
						div_content << text_to_html(context, display.text)
						compose_hidden_div(html, context, link, div_content)
					end
				}
				html
			end
			def add_links(txt, context)
				map = {}
				@model.links.each { |link|
					map.store(link.word, link)
				}
				txt.gsub(/(#{map.keys.join(')|(')})/) { |match|
					if(link = map[match])
						linkify(link, context)
					end.to_s
				}
			end
			def author_to_html(context, author=@model.author)
				args = {
					'class'	=>	'block-author'
				}
				context.p(args) { add_links(author, context) }
			end
			def linkify(link, context)
				if(link.type=='link')
					lnk = HtmlGrid::Link.new(link.word, @model, @session, self)
					lnk.href = link.href
					lnk.value = link.word
					lnk.to_html(context)
				elsif(link.displayelements.size > 1 || link.type == 'text' || link.type == 'html')
					lnk = HtmlGrid::Link.new(link.word, @model, @session, self)
					lnk.href = 'javascript:void(0)'
					lnk.value = link.word
					script = "toggleHiddenDiv('#{link.link_id}-hidden-div')"
					lnk.set_attribute('onclick', script)
					lnk.to_html(context)
				else
					@link_id ||= 0
					@link_id += 1
					link_id = link.link_id
					event = "tooltip_#{link.type}".to_sym
					if(link.type == 'image')
						@images.push(link)
					end
					args = [ :link_id, link_id ]
					url = @lookandfeel.event_url(:tooltip, event, args)
					span = HtmlGrid::Span.new(@model, @session, self)
					span.value = link.word
					span.css_class = 'blue'
					span.css_id = [link.link_id, @link_id].join('_')
					span.dojo_tooltip = url 
					span.to_html(context)
				end
			end
			def text_to_html(context, text=@model.text)
				add_links(text, context) 
			end
			def to_html(context)
				text_to_html(context)
			end
			def title_to_html(context, title=@model.title)
				args = {
					'class'	=>	'block-title'
				}
				context.h1(args) { add_links(title, context) }
			end
		end
		class ArticleTextBlock < View::TextBlock
			def to_html(context)
				html = title_to_html(context)
				html << author_to_html(context)
				add_hidden_divs(html, context)
			end
		end
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
	end
end
