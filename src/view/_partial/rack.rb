require 'view/_partial/art_object'

module DaVaz
  module View
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

    # @api admin
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
