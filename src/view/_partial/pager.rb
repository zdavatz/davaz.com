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
      index        = model.artobjects.map(&:artobject_id)
      active_index = model.artobject ? index.index(model.artobject.artobject_id).to_i : 0
      "Item #{active_index + 1} of #{index.length - 1}"
    end

    def next(model)
      index        = model.artobjects.map(&:artobject_id)
      active_index = model.artobject ? index.index(model.artobject.artobject_id).to_i : 0
      unless (active_index + 1) == index.size
        link = HtmlGrid::Link.new(:paging_next, model, @session, self)
        args = [
          [:artobject_id, index.at(active_index + 1)]
        ]
        unless (search_query = @session.user_input(:search_query)).nil?
          args.unshift([:search_query, search_query])
        end

        unless (artgroup_id = @session.user_input(:artgroup_id)).nil?
          args.unshift([:artgroup_id, artgroup_id])
        end
        link.href = @lookandfeel.event_url(:gallery, :art_object, args)
        image = HtmlGrid::Image.new(:paging_next, model, @session, self)
        image_src  = @lookandfeel.resource(:paging_next)
        image.set_attribute('name', 'paging_next_image')
        image.set_attribute('src', image_src)
        link.value = image
        link
      end
    end

    def last(model)
      index        = model.artobjects.map(&:artobject_id)
      active_index = model.artobject ? index.index(model.artobject.artobject_id).to_i : 0
      unless (active_index - 1) == -1
        link = HtmlGrid::Link.new(:paging_last, model, @session, self)
        args = [
          [:artobject_id, index.at(active_index - 1)]
        ]
        unless (search_query = @session.user_input(:search_query)).nil?
          args.unshift([:search_query, search_query])
        end

        unless (artgroup_id = @session.user_input(:artgroup_id)).nil?
          args.unshift([:artgroup_id, artgroup_id])
        end

        link.href = @lookandfeel.event_url(:gallery, :art_object, args)
        image = HtmlGrid::Image.new(:paging_last, model, @session, self)
        image_src  = @lookandfeel.resource(:paging_last)
        image.set_attribute('name', 'paging_last_image')
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
        [:artobject_id, artobject_id],
        [:serie_id,     serie_id],
      ])
      link.href = "javascript:void(0)"
      link.set_attribute('onclick', <<~TGGL)
        toggleShow(
          'show', '#{url}', 'desk', 'show_wipearea',
          '#{serie_id}', '#{artobject_id}');
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
      index        = model.artobjects.map(&:artobject_id)
      active_index = model.artobject ? index.index(model.artobject.artobject_id).to_i : 0
      "Item #{active_index + 1} of #{index.length - 1}"
    end

    def next(model)
      index        = model.artobjects.map(&:artobject_id)
      active_index = model.artobject ? index.index(model.artobject.artobject_id).to_i : 0
      unless (active_index + 1) == index.size
        link = HtmlGrid::Link.new(:paging_next, model, @session, self)
        args = [
          [:artgroup_id, @session.user_input(:artgroup_id)],
          [:artobject_id, index.at(active_index + 1)],
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
      index        = model.artobjects.map(&:artobject_id)
      active_index = model.artobject ? index.index(model.artobject.artobject_id).to_i : 0
      unless (active_index - 1) == -1
        link = HtmlGrid::Link.new(:paging_last, model, @session, self)
        link.href = @lookandfeel.event_url(:communication, :shop_art_object, [
          [:artgroup_id,  @session.user_input(:artgroup_id)],
          [:artobject_id, index.at(active_index - 1)]
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
