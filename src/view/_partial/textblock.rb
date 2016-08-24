require 'uri'
require 'htmlgrid/namedcomponent'
require 'htmlgrid/span'
require 'htmlgrid/link'
require 'htmlgrid/image'
require 'util/image_helper'
require 'view/_partial/live_editor'

module DaVaz::View
  module TextBlockLinksMethods
    def add_links(txt, context)
      map = {}
      @model.links.each { |link|
        map.store(link.word, link)
      }
      txt.gsub(/(#{map.keys.join(')|(')})/) { |match|
        if link = map[match]
          linkify(link, context)
        end.to_s
      }
    end

    def linkify(link, context)
      if link.artobjects.size == 1
        artobject = link.artobjects.first
        if artobject.is_url?
          lnk = HtmlGrid::Link.new(link.word, @model, @session, self)
          lnk.href  = artobject.url
          lnk.value = link.word
          lnk.to_html(context)
        else
          @link_id ||= 0
          @link_id += 1
          span = HtmlGrid::Span.new(@model, @session, self)
          span.value     = link.word
          span.css_id    = ['tooltip', link.link_id, @link_id].join('_')
          span.css_class = 'tooltip blue'
          span.set_attribute(
            :href,
            @lookandfeel.event_url(:tooltip, :tooltip, [
              [:artobject_id, artobject.artobject_id]
            ])
          )
          span.to_html(context)
        end
      elsif link.artobjects.size > 1
        lnk = HtmlGrid::Link.new(link.word, @model, @session, self)
        lnk.href  = 'javascript:void(0)'
        lnk.value = link.word
        lnk.set_attribute('onclick', <<~EOS)
          return toggleHiddenDiv('#{link.link_id}-hidden-div');
        EOS
        lnk.to_html(context)
      end
    end
  end

  class TextBlock < HtmlGrid::Component
    include TextBlockLinksMethods

    def add_hidden_divs(html, context)
      links = @model.links
      links.each { |link|
        div_content = ""
        if link.artobjects.size > 1
          link.artobjects.each { |aobject|
            artobject_id = aobject.artobject_id
            image = HtmlGrid::Image.new(artobject_id, \
              @model, @session, self)
            url = DaVaz::Util::ImageHelper.image_url(artobject_id)
            image.set_attribute('src', url)
            div_content << image.to_html(context)
            if aobject.text
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
      args = {
        'class' => 'block-image',
        'id'    => "artobject_image_#{@model.artobject_id}",
      }
      if DaVaz::Util::ImageHelper.has_image?(artobject_id)
        image = HtmlGrid::Image.new(artobject_id, @model, @session, self)
        url = DaVaz::Util::ImageHelper.image_url(artobject_id)
        image.set_attribute('src', url)
        image.css_id = @model.artobject_id
        div = context.div(args) { image.to_html(context) }
      else
        div = context.div(args) {}
      end
    end

    def author_to_html(context)
      return '' if @model.author.empty?
      context.div('class' => 'block-author') {
        add_links(@model.author, context)
      }
    end

    def compose_hidden_div(html, context, link, div_content)
      html << context.div(
        'class' => 'hidden-div',
        'id'    => "#{link.link_id}_hidden_div",
      ) {
        hide_link(link, context) << div_content << hide_link(link, context)
      }
    end

    def date_to_html(context)
      return '' if @model.date == '0000-00-00'
      context.div('class' => 'block-date') { @model.date_ch }
    end

    def hide_link(link, context)
      hide_link = HtmlGrid::Link.new(:hide_link, @model,
        @session, self)
      hide_link.href = 'javascript:void(0);'
      span = HtmlGrid::Span.new(@model, @session, self)
      span.css_class = 'hide-hidden-div-link'
      span.value     = @lookandfeel.lookup(:hide)
      hide_link.value = span.to_html(context)
      hide_link.set_attribute('onclick', <<~EOS)
        return toggleHiddenDiv('#{link.link_id}-hidden-div');
      EOS
      hide_link.to_html(context)
    end

    def text_to_html(context)
      return '' if @model.text.empty?
      context.div('class' => 'block-text') {
        add_links(@model.text, context)
      }
    end

    def url_to_html(context)
      parsed = URI.parse(@model.url)
      parsed = URI.parse('http://' + @model.url) unless parsed.scheme
      context.div('class' => 'block-url') {
        context.a(
          'href'   => parsed,
          'target' => '_blank',
        ) {
          @model.url
        }
      }
    rescue URI::InvalidURIError
      ''
    end

    def title_to_html(context)
      return '' if @model.title.empty?
      context.div('class' => 'block-title') {
        link = context.a('name' => @model.title.downcase.gsub(/\s+/, '')) {
          add_links(@model.title, context)
        }
      }
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

  class AdminTextBlock < HtmlGrid::Component
  end

  class AdminTextBlockList < HtmlGrid::DivList
    COMPONENTS = {
      [0, 0] => AdminLiveEditor
    }
  end
end
