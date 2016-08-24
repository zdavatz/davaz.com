require 'cgi'
require 'htmlgrid/div'
require 'htmlgrid/component'
require 'htmlgrid/dojotoolkit'
require 'util/image_helper'
require 'ext/htmlgrid/component'

module DaVaz::View
  # @api admin
  class AdminLiveEditor < HtmlGrid::Div
    def compose_widget_props
      props = {
        'class'                 => 'tundra',
        'element_id_name'       => 'artobject_id',
        'element_id_value'      =>  @model.artobject_id,
        'update_url'            => @lookandfeel.event_url(
          :admin, :ajax_save_live_edit),
        'delete_icon_src'       => @lookandfeel.resource(:icon_cancel),
        'delete_icon_txt'       => @lookandfeel.lookup(:delete),
        'delete_image_icon_src' => @lookandfeel.resource(:icon_delete),
        'delete_image_icon_txt' => @lookandfeel.lookup(:delete_image),
        'add_image_icon_src'    => @lookandfeel.resource(:icon_add),
        'add_image_icon_txt'    => @lookandfeel.lookup(:add_image),
        'delete_item_url'  => @lookandfeel.event_url(
          @session.zone, :ajax_delete_element, {
            :artobject_id => @model.artobject_id
          }),
        'delete_image_url' => @lookandfeel.event_url(
          @session.zone, :ajax_delete_image, {
            :artobject_id => @model.artobject_id
          }),
        'upload_form_url' => @lookandfeel.event_url(
          @session.zone, :ajax_upload_image_form, {
            :artobject_id => @model.artobject_id
          })
      }
      if DaVaz::Util::ImageHelper.has_image?(@model.artobject_id)
        props['has_image'] = 'true'
        props['image_url'] = DaVaz::Util::ImageHelper.image_url(
          @model.artobject_id, nil, true)
      else
        props['has_image'] = 'false'
      end
      props['image_pos'] = 3

      values = []
      fields = @model.serie =~ /\AHis\sLife\z/ ? \
        %i{title url text} : %i{title url date_ch text}
      fields.each { |field|
        value = @model.send(field)
        if value && !value.empty? # key, value
          values.push(field.to_s)
          values.push(CGI.escapeHTML(value).gsub(',','<comma/>'))
        end
      }
      props['values'] = values
      props
    end

    def to_html(context)
      dojo_tag('ywesee.widget.live_editor', {
        'data-dojo-props' => dojo_props(compose_widget_props)
      }).to_html(context)
    end
  end

  # @api admin
  class AdminGuestbookLiveEditor < HtmlGrid::Div
    def compose_widget_props
      props = {
        'update_url'       => @lookandfeel.event_url(
          :admin, :ajax_save_gb_live_edit),
        'delete_item_url'  => @lookandfeel.event_url(
           @session.zone, :ajax_delete_guest, {:guest_id => @model.guest_id}),
        'delete_icon_src'  => @lookandfeel.resource(:icon_cancel),
        'delete_icon_txt'  => @lookandfeel.lookup(:delete),
        'labels'           => true,
        'class'            => 'tundra',
        'element_id_name'  => 'guest_id',
        'element_id_value' => @model.guest_id
      }
      values = []
      [:name, :date_gb, :city, :country, :text].each { |field|
        value = @model.send(field)
        if value && !value.empty? # key, value, label
          values.push(field.to_s)
          values.push(CGI.escapeHTML(value)
            .gsub(',', '<comma/>').gsub(/\n/, '<br/>'))
          values.push(@lookandfeel.lookup(field))
        end
      }
      props['values'] = values
      props
    end

    def to_html(context)
      dojo_tag('ywesee.widget.live_editor', {
        'data-dojo-props' => dojo_props(compose_widget_props)
      }).to_html(context)
    end
  end
end
