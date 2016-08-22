require 'htmlgrid/divcomposite'
require 'htmlgrid/divlist'
require 'htmlgrid/errormessage'
require 'htmlgrid/inputfile'
require 'htmlgrid/link'
require 'htmlgrid/image'
require 'view/template'
require 'view/_partial/form'
require 'view/_partial/select'
require 'view/_partial/image'
require 'view/_partial/tag'
require 'view/_partial/pager'

# ArtObjects
#
#   * Drawings
#   * Paitings
#   * Multiples
#   * Movies
#   * Photos
#   * Designs
#   * Schnitzenthesen
module DaVaz::View
  class ArtobjectDetails < HtmlGrid::DivComposite
    COMPONENTS = {
      [0, 0] => :serie,
      [0, 1] => :tool,
      [0, 2] => :material,
      [0, 3] => :size,
      [0, 4] => :date,
      [0, 5] => :location,
      [0, 6] => :country,
      [0, 7] => :language
    }
  end

  class ArtObjectInnerComposite < HtmlGrid::DivComposite
    CSS_ID = 'artobject_inner_composit'
    COMPONENTS = {
      [0, 0] => :title,
      [0, 1] => :artgroup,
      [0, 2] => :artcode,
      [0, 3] => :image,
      [0, 4] => ArtobjectDetails,
      [0, 5] => :url,
      [0, 6] => :text,
      [0, 7] => :wordpress_url
    }
    CSS_ID_MAP = {
      0 => 'artobject_title',
      1 => 'artobject_subtitle_left',
      2 => 'artobject_subtitle_right',
      3 => 'artobject_image',
      4 => 'artobject_details',
      5 => 'artobject_google_video_url',
      6 => 'artobject_text',
      7 => 'artobject_wordpress_url',
    }

    def image(model=@model)
      return '' unless model
      img = HtmlGrid::Image.new(model.artobject_id, model, @session, self)
      img.css_id = 'artobject_image'
      img.set_attribute(
        'src', DaVaz::Util::ImageHelper.image_url(model.artobject_id))
      return img if model.url.empty?
      link = HtmlGrid::HttpLink.new(:url, model, @session, self)
      link.href  = model.url
      link.value = img
      link.set_attribute('target', '_blank')
      link
    end

    def url(model=@model)
      return '' if !model || !model.url || model.url.empty?
      link = HtmlGrid::HttpLink.new(
        :google_video_link, model, @session, self)
      link.href  = model.url
      link.value = @lookandfeel.lookup(:watch_movie)
      link.set_attribute('target', '_blank')
      link
    end

    def wordpress_url(model=@model)
      return '' if !model || !model.wordpress_url || model.wordpress_url.empty?
      link = HtmlGrid::HttpLink.new(:wordpress_link, model, @session, self)
      link.href  = model.url
      link.value = @lookandfeel.lookup(:read_wordpress)
      link.set_attribute('target', '_blank')
      link
    end
  end

  class MoviesArtObjectOuterComposite < HtmlGrid::DivComposite
    COMPONENTS = {
      [0, 0] => MoviesPager,
      [0, 1] => :back_to_overview
    }
    CSS_ID_MAP = {
      0 => 'artobject_pager',
      1 => 'artobject_back_link'
    }

    def back_to_overview(model)
      link = HtmlGrid::Link.new(:back_to_overview, model, @session, self)
      link.href = 'javascript:void(0);'
      link.set_attribute('onclick', <<~EOS)
        return showMovieGallery('movies_gallery_view', 'movies_list', '');
      EOS
      link
    end
  end

  class ArtObjectOuterComposite < HtmlGrid::DivComposite
    COMPONENTS = {
      [0, 0] => :pager,
      [0, 1] => :back_to_overview,
    }
    CSS_ID_MAP = {
      0 => 'artobject_pager',
      1 => 'artobject_back_link',
    }

    def back_to_overview(model)
      return '' if @model.artobjects.empty?
      link = HtmlGrid::Link.new(:back_to_overview, model, @session, self)
      link.href = @lookandfeel.event_url(:gallery, :search, [
        [:artgroup_id,  @session.user_input(:artgroup_id)],
        [:search_query, @session.user_input(:search_query)]
      ])
      link
    end

    def pager(model)
      unless @model.artobjects.empty?
        Pager.new(model, @session, self)
      end
    end
  end

  class MoviesArtObjectComposite < HtmlGrid::DivComposite
    COMPONENTS = {
      [0, 0] => MoviesArtObjectOuterComposite,
      [0, 1] => component(ArtObjectInnerComposite, :artobject)
    }
    CSS_ID_MAP = {
      0 => 'artobject_outer_composite',
      1 => 'artobject_inner_composite'
    }
    HTTP_HEADERS = {
      'type'    => 'text/html',
      'charset' => 'UTF-8'
    }
  end

  class ArtObjectComposite < HtmlGrid::DivComposite
    COMPONENTS = {
      [0, 0] => ArtObjectOuterComposite,
      [0, 1] => component(ArtObjectInnerComposite, :artobject)
    }
    CSS_ID_MAP = {
      0 => 'artobject_outer_composite',
      1 => 'artobject_inner_composite'
    }
  end

  class ArtObject < GalleryTemplate
    CONTENT = ArtObjectComposite
  end

  class ShopArtObjectOuterComposite < HtmlGrid::DivComposite
    COMPONENTS = {
      [0, 0] => :pager,
      [0, 1] => :back_to_shop
    }
    CSS_ID_MAP = {
      0 => 'artobject_pager',
      1 => 'artobject_back_link'
    }

    def back_to_shop(model)
      link = HtmlGrid::Link.new(:back_to_shop, model, @session, self)
      link.href = @lookandfeel.event_url(:communication, :shop)
      link
    end

    def pager(model)
      unless @model.artobjects.empty?
        ShopPager.new(model, @session, self)
      end
    end
  end

  class ShopArtObjectComposite < HtmlGrid::DivComposite
    COMPONENTS = {
      [0, 0] => ShopArtObjectOuterComposite,
      [0, 1] => component(ArtObjectInnerComposite, :artobject)
    }
    CSS_ID_MAP = {
      0 => 'artobject_outer_composite',
      1 => 'artobject_inner_composite'
    }
  end

  class ShopArtObject < GalleryTemplate
    CONTENT = ShopArtObjectComposite
  end

  class AddFormComposite < HtmlGrid::DivComposite
    COMPONENTS = {
      [0, 0] => :input_field,
      [1, 0] => :submit,
      [2, 0] => 'pipe_divider',
      [3, 0] => :cancel,
    }

    def build_script(model)
      name = model.name
      url  = @lookandfeel.event_url(:gallery, :ajax_add_element, [
        [:select_name,  name],
        [:select_value, '']
      ])
      <<~EOS.gsub(/^\s*|\n/, '')
        var value  = document.artobjectform.#{name}_add_form_input.value
          , select = document.artobjectform.#{name}_id_select
          ;
        return addElement(
          select
        , '#{url}'
        , value
        , '#{name}_add_form'
        , '#{name}_remove_link'
        );
      EOS
    end

    def input_field(model)
      input = HtmlGrid::InputText.new(
        "#{model.name}_add_form_input", model, @session, self)
      input.set_attribute('onkeypress', <<~EOS.gsub(/^\s*|\n/, ''))
        if (event.keyCode == '13') {
          #{build_script(model)}
          return false;
        }
      EOS
      input
    end

    def submit(model)
      link = HtmlGrid::Link.new(:submit, model, @session, self)
      link.href = 'javascript:void(0);'
      link.set_attribute('onclick', build_script(model))
      link
    end

    def cancel(model)
      link = HtmlGrid::Link.new(:cancel, model, @session, self)
      link.href = 'javascript:void(0);'
      link.set_attribute('onclick', <<~EOS.gsub(/^\s*|\n/, ''))
        return toggleInnerHTML('#{model.name}_add_form', 'null');
      EOS
      link
    end
  end

  class EditLinks < HtmlGrid::DivComposite
    COMPONENTS = {
      [0, 0] => :add,
      [1, 0] => 'pipe_divider',
      [2, 0] => :remove,
      [0, 1] => :add_form
    }

    def init
      css_id_map.store(1, "#{@model.name}_add_form")
      super
    end

    def add(model)
      link = HtmlGrid::Link.new("add_#{model.name}", model, @session, self)
      link.href = 'javascript:void(0);'
      link.set_attribute('onclick', <<~EOS.gsub(/(^\s*)|\n/, ''))
        return toggleInnerHTML(
          '#{model.name}_add_form'
        , '#{@lookandfeel.event_url(:gallery, :ajax_add_form, [
            [:artobject_id, model.artobject.artobject_id],
            [:name,         model.name ]
          ])}'
        );
      EOS
      link
    end

    def remove(model)
      link = HtmlGrid::Link.new(
        "remove_#{model.name}", model, @session, self)
      link.css_id = "#{model.name}_remove_link"
      link.href   = 'javascript:void(0);'
      link.set_attribute('onclick', <<~EOS.gsub(/(^\s*)|\n/, ''))
        return removeElement(
          document.artobjectform.#{model.name}_id
        , '#{@lookandfeel.event_url(:gallery, :ajax_remove_element, [
              [:artobject_id, model.artobject.artobject_id],
              [:select_name,  model.name],
              [:selected_id,  ''],
            ])
          }'
        , '#{link.css_id}'
        );
      EOS
      link
    end

    def add_form(model)
      ''
    end
  end

  class AdminArtObjectDetails < Form
    include HtmlGrid::ErrorMessage

    DEFAULT_CLASS = HtmlGrid::InputText
    CSS_ID = 'artobject_details'
    EVENT  = :update
    LABELS = true
    FORM_METHOD = 'POST'
    FORM_NAME   = 'artobjectform'
    COMPONENTS  = {
      [0,  0]    => :title,
      [0,  1]    => component(DynSelect, :select_artgroup, 'artgroup_id'),
      [0,  2]    => component(DynSelect, :select_serie, 'serie_id'),
      [1,  3]    => :serie,
      [0,  4]    => :serie_position,
      [0,  5]    => :tags,
      [1,  6]    => ShowAllTagsLink,
      [0,  7]    => component(DynSelect, :select_tool, 'tool_id'),
      [1,  8]    => :tool,
      [0,  9]    => component(DynSelect, :select_material, 'material_id'),
      [1, 10]    => :material,
      [0, 11]    => :size,
      [0, 12]    => :date,
      [0, 13]    => :location,
      [0, 14]    => component(DynSelect, :select_country, 'country_id'),
      [0, 15]    => :form_language,
      [0, 16]    => :url,
      [0, 17]    => :price,
      [0, 18]    => :wordpress_url,
      [0, 20]    => :text_label,
      [1, 20]    => :text,
      [1, 21, 1] => :update,
      [1, 21, 2] => :reset,
      [1, 22, 1] => :new_art_object,
      [1, 22, 2] => :delete
    }
    CSS_MAP = {
      [0, 0]  => 'label red',
      [0, 1]  => 'label red',
      [0, 2]  => 'label red',
      [1, 2]  => 'serie_id_container',
      [0, 4]  => 'label red',
      [0, 7]  => 'label red',
      [1, 7]  => 'tool_id_container',
      [0, 9]  => 'label red',
      [1, 9]  => 'material_id_container',
      [0, 12] => 'label red',
      [0, 14] => 'label red',
      [0, 20] => 'label'
    }
    LOOKANDFEEL_MAP = {
      :form_language => :language,
    }

    # edit links
    %i{serie tool material}.map do |method|
      define_method(method) do |model|
        model.name = method.to_s
        EditLinks.new(model, @session, self)
      end
    end

    def init
      super
      error_message
      self.onsubmit = <<~EOS.gsub(/(^\s*)|\n/, '')
        (function(e) {
          e.preventDefault();

          return require([
            'dojo/query'
          , 'dijit/dijit'
          ], function(query ,dijit) {
            var form   = query('form[name=artobjectform]')[0]
              , editor = dijit.byId('#{html_editor_id(@model)}')
              ;
            form.text.value = editor.value;
            form.submit();
            return true;
          });
        })(event);
      EOS
    end

    def hidden_fields(context)
      hidden_fields = super
      hidden_fields <<
        context.hidden('artobject_id', @model.artobject.artobject_id) <<
        context.hidden('old_serie_id', @model.artobject.serie_id)

      if @model.fragment
        hidden_fields << context.hidden('fragment', @model.fragment)
      end

      if search_query = @session.user_input(:search_query)
        hidden_fields << context.hidden('search_query', search_query)
      end

      if obj = @model.artobject
        hidden_fields << context.hidden('text', escape(obj.text))
      end
      hidden_fields
    end

    def input_text(symbol, maxlength='50', size='50')
      input = HtmlGrid::InputText.new(
        symbol, model.artobject, @session, self)
      input.set_attribute('size', size)
      input.set_attribute('maxlength', maxlength)
      input
    end

    def date(model)
      input = HtmlGrid::InputText.new(:date, model, @session, self)
      begin
        date = model.artobject.date
        date = Date.parse(date) unless date.is_a?(Date)
        input.value = date.strftime('%d.%m.%y')
      rescue ArgumentError
        input.value = '01.01.1970'
      rescue NoMethodError
        input.value = '00.00.0000'
      end
      input.set_attribute('size', '10')
      input.set_attribute('maxlength', '10')
      input
    end

    def delete(model)
      obj = model.artobject
      return '' unless obj
      args = [
        ['artobject_id', obj.artobject_id],
        ['fragment',     model.fragment],
        ['state_id',     @session.state.object_id.to_s]
      ]
      if search_query = @session.user_input(:search_query)
        args.push([:search_query, search_query])
      else
        args.push([:artgroup_id, obj.artgroup_id])
      end
      url = @lookandfeel.event_url(:admin, :delete, args)
      button = HtmlGrid::Button.new(:delete, model, @session, self)
      button.set_attribute('onclick', <<~EOS.gsub(/(^\s*)|\n/, ''))
        if (confirm('Do you really want to delete this artobject?')) {
          window.location.href = '#{url}';
        }
      EOS
      button
    end

    def form_language(model)
      input = input_text(:language, '150')
      input.set_attribute('name', 'form_language')
      input
    end

    def location(model)
      input_text(:location)
    end

    def new_art_object(model)
      return '' unless model.artobject.artobject_id
      button = HtmlGrid::Button.new(:new_art_object, model, @session, self)
      button.set_attribute('onclick', <<~EOS.gsub(/(^\s*)|\n/, ''))
        window.location.href =
          '#{@lookandfeel.event_url(:gallery, :new_art_object)}';
      EOS
      button
    end

    def price(model)
      input_text(:price, '10')
    end

    def reset(model)
      button = HtmlGrid::Button.new(:reset, model, @session, self)
      button.set_attribute('type', 'reset')
      button
    end

    def serie_position(model)
      input_text(:serie_position, '4')
    end

    def size(model)
      input_text(:size)
    end

    def title(model)
      input_text(:title, '150')
    end

    def text_label(model)
      @lookandfeel.lookup(:text)
    end

    # @note The id attribute needs unique value for dojo widget
    def text(model)
      dojo_tag('dijit.Editor', {
        'data-dojo-props': "id: '#{html_editor_id(model)}', class: 'tundra'"
      }, model.artobject.text)
    end

    def tags(model)
      input_text(:tags_to_s)
    end

    def update(model)
      key = (model.artobject.artobject_id ? :update : :save)
      button = HtmlGrid::Button.new(key, model, @session, self)
      button.set_attribute('type', 'submit')
      button
    end

    def url(model)
      input_text(:url, '150')
    end

    def wordpress_url(model)
      input_text(:wordpress_url, '300', '80')
    end

    private

    # Creates id for html editor (dijit.Editor) using model artobject_id.
    # The id will be 0 for new art object.
    #
    # @param [OpenStruct] model the model object cotnains artobject
    # @return [String] Id string for html editor widget
    def html_editor_id(model)
      obj = model.artobject
      "html_editor_#{obj.artgroup.downcase}_" +
        ((!obj || !obj.artobject_id) ? '0' : obj.artobject_id.to_s)
    end
  end

  # @api admin
  class AdminArtObjectInnerComposite < HtmlGrid::DivComposite
    COMPONENTS = {
      [0, 0] => :artcode,
      [0, 1] => AdminImageDiv,
      [0, 2] => AdminAjaxUploadImageForm,
      [0, 3] => :error_message_container,
      [0, 4] => AdminArtObjectDetails,
    }
    CSS_ID_MAP = {
      0 => 'artobject_title',
      2 => 'artobject_image_upload_form',
      3 => 'artobject_error_message_container',
      4 => 'artobject_admin_details',
    }
    SYMBOL_MAP = {
      :artcode => HtmlGrid::Value,
    }

    def init
      css_id_map.store(1, "artobject_image_#{@model.artobject.artobject_id}")
      super
    end

    def artcode(model)
      model.artobject.artcode
    end

    def url(model)
      url = mode.artobject.url
      return '' unless url.empty?
      link = HtmlGrid::HttpLink.new(
        :google_video_link, model.artobject, @session, self)
      link.href = url
      link.value = @lookandfeel.lookup(:watch_movie)
      link.set_attribute('target', '_blank')
      link
    end
  end

  class AdminArtObjectComposite < HtmlGrid::DivComposite
    COMPONENTS = {
      [0, 0] => ArtObjectOuterComposite,
      [0, 1] => AdminArtObjectInnerComposite
    }
    CSS_ID_MAP = {
      0 => 'artobject_outer_composite',
      1 => 'artobject_inner_composite',
    }
    HTTP_HEADERS = {
      'type'    => 'text/html',
      'charset' => 'UTF-8'
    }
  end

  class AdminMoviesArtObjectComposite < HtmlGrid::DivComposite
    COMPONENTS = {
      [0, 0] => MoviesArtObjectOuterComposite,
      [0, 1] => AdminArtObjectInnerComposite
    }
    CSS_ID_MAP = {
      0 => 'artobject_outer_composite',
      1 => 'artobject_inner_composite'
    }
    HTTP_HEADERS = {
      'type'    => 'text/html',
      'charset' => 'UTF-8'
    }
  end

  class AdminArtObject < AdminGalleryTemplate
    CONTENT = AdminArtObjectComposite
  end
end
