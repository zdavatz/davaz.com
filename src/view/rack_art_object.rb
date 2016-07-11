require 'view/art_object'

module DAVAZ
  module View
    class RackPager < Pager

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
            'show', '#{url}', 'desk', null, '#{serie_id}', '#{artobject_id}');
        TGGL
        link
      end

      def next(model)
        unless (link = super).nil?
          link = super
          pager_link(link)
        end
      end

      def last(model)
        unless (link = super).nil?
          link = super
          pager_link(link)
        end
      end
    end

    class RackArtObjectOuterComposite < HtmlGrid::DivComposite
      COMPONENTS = {
        [0, 0] => RackPager,
        [0, 1] => :back_to_overview,
      }
      CSS_ID_MAP = {
        0 => 'artobject_pager',
        1 => 'artobject_back_link',
      }

      def back_to_overview(model)
        link = HtmlGrid::Link.new(:back_to_overview, model, @session, self)
        link.href = 'javascript:void(0)'
        url = @lookandfeel.event_url(:gallery, :ajax_rack, [
          [:serie_id, @session.user_input(:serie_id)]
        ])
        link.set_attribute('onclick', <<~TGGL)
          toggleShow('show', '#{url}', 'desk', 'show_wipearea');
        TGGL
        link
      end
    end

    class RackArtObjectComposite < HtmlGrid::DivComposite
      COMPONENTS = {
        [0, 0] => RackArtObjectOuterComposite,
        [0, 1] => component(ArtObjectInnerComposite, :artobject),
      }
      CSS_ID_MAP = {
        0 => 'artobject_outer_composite',
        1 => 'artobject_inner_composite',
      }
      HTTP_HEADERS = {
        'type'    => 'text/html',
        'charset' => 'UTF-8',
      }
    end

    class AdminRackArtObjectComposite < HtmlGrid::DivComposite
      COMPONENTS = {
        [0, 0] => RackArtObjectOuterComposite,
        [0, 1] => View::AdminArtObjectInnerComposite,
      }
      CSS_ID_MAP = {
        0 => 'artobject_outer_composite',
        1 => 'artobject_inner_composite',
      }
      HTTP_HEADERS = {
        'type'    => 'text/html',
        'charset' => 'UTF-8',
      }
    end
  end
end
