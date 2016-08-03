require 'cgi'
require 'htmlgrid/div'
require 'htmlgrid/component'
require 'htmlgrid/dojotoolkit'
require 'util/image_helper'

module DaVaz::View
  # @api admin
  class AdminLiveEditWidget < HtmlGrid::Div
    def compose_element_args
      args = [
        ['class', 'tundra'],
        ['element_id_name', 'artobject_id'],
        ['element_id_value', @model.artobject_id]
      ]
      values = []
      fields = @model.serie =~ /\AHis\sLife\z/ ? \
        %i{title url text} : %i{title url date_ch text}
      fields.each { |symbol|
        value = @model.send(symbol)
        if value && !value.empty?
          values.push(symbol.to_s)
          values.push(CGI.escapeHTML(value).gsub(',','<comma/>'))
        end
      }
      args.push(['values', values])
      args
    end

    def to_html(context)
      url = @lookandfeel.event_url(:admin, :ajax_save_live_edit)
      object_args = {
        :artobject_id => @model.artobject_id,
      }
      args = [
        ['update_url', url],
        ['delete_icon_src', @lookandfeel.resource(:icon_cancel)],
        ['delete_icon_txt', @lookandfeel.lookup(:delete)],
        ['delete_image_icon_src', @lookandfeel.resource(:icon_delete)],
        ['delete_image_icon_txt', @lookandfeel.lookup(:delete_image)],
        ['add_image_icon_src', @lookandfeel.resource(:icon_add)],
        ['add_image_icon_txt', @lookandfeel.lookup(:add_image)],
        ['delete_item_url', @lookandfeel.event_url(
          @session.zone, :ajax_delete_element, object_args)],
        ['delete_image_url', @lookandfeel.event_url(
          @session.zone, :ajax_delete_image, object_args)],
        ['upload_form_url', @lookandfeel.event_url(
          @session.zone, :ajax_upload_image_form, object_args)]

      ]
      if DaVaz::Util::ImageHelper.has_image?(@model.artobject_id)
        args.push(['has_image', 'true'])
        args.push(['image_url', DaVaz::Util::ImageHelper.image_url(
          @model.artobject_id, nil, true)])
      else
        args.push(['has_image', 'false'])
      end
      args.push(['image_pos', 3])
      dojo_tag(
        'ywesee.widget.EditWidget',
        args.concat(compose_element_args)
      ).to_html(context)
    end
  end

  # @api admin
  class AdminGuestbookLiveEditWidget < HtmlGrid::Div
    def compose_element_args
      args = [
        ['class', 'tundra'],
        ['element_id_name', 'guest_id'],
        ['element_id_value', @model.guest_id],
      ]
      values = []
      [:name, :date_gb, :city, :country, :text].each { |symbol|
        unless((value = @model.send(symbol)).nil? || value.empty?)
          values.push(symbol.to_s)
          values.push(CGI.escapeHTML(value)
            .gsub(',','<comma/>').gsub(/\n/, '<br/>'))
          values.push(@lookandfeel.lookup(symbol))
        end
      }
      args.push(['values', values])
      args
    end

    def to_html(context)
      url = @lookandfeel.event_url(:admin, :ajax_save_gb_live_edit)
      object_args = {
        :guest_id => @model.guest_id,
      }
      args = [
        ['update_url', url],
        ['delete_item_url', @lookandfeel.event_url(
          @session.zone, :ajax_delete_guest, object_args)],
        ['delete_icon_src', @lookandfeel.resource(:icon_cancel)],
        ['delete_icon_txt', @lookandfeel.lookup(:delete)],
        ['labels', true ]
      ]
      dojo_tag(
        'ywesee.widget.EditWidget',
        args.concat(compose_element_args)
      ).to_html(context)
    end
  end
end
