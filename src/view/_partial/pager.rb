require 'htmlgrid/spancomposite'
require 'htmlgrid/link'
require 'htmlgrid/image'

module DaVaz::View
  class Pager < HtmlGrid::SpanComposite
    COMPONENTS = {
      [0, 0] => :last,
      [0, 1] => :items,
      [0, 2] => :next
    }

    def items(model)
      "Item #{model.artobjects.index(model.artobject).to_i + 1} of" \
      " #{model.artobjects.size}"
    end

    def next(model)
      artobjects = model.artobjects
      active_index = artobjects.index(model.artobject).to_i
      unless (active_index + 1) == artobjects.size
        link = HtmlGrid::Link.new(:paging_next, model, @session, self)
        args = [
          [:artobject_id, artobjects.at(active_index+1).artobject_id]
        ]
        unless (search_query = @session.user_input(:search_query)).nil?
          args.unshift([ :search_query, search_query])
        end

        unless (artgroup_id = @session.user_input(:artgroup_id)).nil?
          args.unshift([ :artgroup_id, artgroup_id])
        end
        link.href = @lookandfeel.event_url(:gallery, :art_object, args)
        image = HtmlGrid::Image.new(:paging_next, model, @session, self)
        image_src = @lookandfeel.resource(:paging_next)
        image.set_attribute('src', image_src)
        link.value = image
        link
      end
    end

    def last(model)
      artobjects = model.artobjects
      active_index = artobjects.index(model.artobject).to_i
      unless (active_index - 1) == -1
        link = HtmlGrid::Link.new(:paging_last, model, @session, self)
        args = [
          [:artobject_id, artobjects.at(active_index-1).artobject_id]
        ]
        unless (search_query = @session.user_input(:search_query)).nil?
          args.unshift([ :search_query, search_query])
        end

        unless (artgroup_id = @session.user_input(:artgroup_id)).nil?
          args.unshift([ :artgroup_id, artgroup_id])
        end

        link.href = @lookandfeel.event_url(:gallery, :art_object, args)
        image = HtmlGrid::Image.new(:paging_last, model, @session, self)
        image_src = @lookandfeel.resource(:paging_last)
        image.set_attribute('src', image_src)
        link.value = image
        link
      end
    end
  end

  class RackPager < Pager
    %i{next last}.map do |method|
      define_method(method) do |model|
        link = super(model)
        return nil unless link
        pager_link(link)
      end
    end

    private

    def pager_link(link)
      artobject_id = link.attributes['href'].split('/').last
      serie_id     = @session.user_input(:serie_id)
      url = @lookandfeel.event_url(:gallery, :ajax_rack, [
        [:serie_id, serie_id],
        [:artobject_id, artobject_id],
      ])
      link.href = "javascript:void(0)"
      link.set_attribute('onclick', <<~TGGL)
        toggleShow(
          'show', '#{url}', 'desk', 'show_wipearea', '#{serie_id}', '#{artobject_id}');
      TGGL
      link
    end
  end

  class MoviesPager < Pager
    %i{next last}.map do |method|
      define_method(method) do |model|
        link = super(model)
        return nil unless link
        pager_link(link)
      end
    end

    private

    def pager_link(link)
      artobject_id = link.attributes['href'].split('/').last
      link.href = 'javascript:void(0);'
      link.set_attribute('onclick', <<~EOS.gsub(/(^\s*)|\n/, ''))
        return toggleInnerHTML(
          'movies_gallery_view'
        , '#{@lookandfeel.event_url(:gallery, :ajax_movie_gallery, [
              [:artobject_id, artobject_id]
          ])}'
        , '#{artobject_id}'
        );
      EOS
      link
    end
  end

  class ShopPager < Pager
    COMPONENTS = {
      [0, 0] => :last,
      [0, 1] => :items,
      [0, 2] => :next,
    }

    def items(model)
      "Item #{model.artobjects.index(model.artobject).to_i + 1} of" \
      " #{model.artobjects.size}"
    end

    def next(model)
      artobjects = model.artobjects
      active_index = artobjects.index(model.artobject).to_i
      unless (active_index + 1) == artobjects.size
        link = HtmlGrid::Link.new(:paging_next, model, @session, self)
        args = [
          [:artgroup_id, @session.user_input(:artgroup_id)],
          [:artobject_id, artobjects.at(active_index + 1).artobject_id],
        ]
        link.href = @lookandfeel.event_url(
          :communication, :shop_art_object, args)
        image = HtmlGrid::Image.new(:paging_next, model, @session, self)
        image_src = @lookandfeel.resource(:paging_next)
        image.set_attribute('src', image_src)
        link.value = image
        link
      end
    end

    def last(model)
      artobjects = model.artobjects
      active_index = artobjects.index(model.artobject).to_i
      unless (active_index - 1) == -1
        link = HtmlGrid::Link.new(:paging_last, model, @session, self)
        link.href = @lookandfeel.event_url(:communication, :shop_art_object, [
          [:artgroup_id,  @session.user_input(:artgroup_id)],
          [:artobject_id, artobjects.at(active_index-1).artobject_id]
        ])
        image = HtmlGrid::Image.new(:paging_last, model, @session, self)
        image_src = @lookandfeel.resource(:paging_last)
        image.set_attribute('src', image_src)
        link.value = image
        link
      end
    end
  end
end
