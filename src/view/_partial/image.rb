require 'htmlgrid/div'
require 'htmlgrid/image'
require 'htmlgrid/link'
require 'htmlgrid/divcomposite'
require 'htmlgrid/inputfile'
require 'view/_partial/form'

module DaVaz::View
  # @api admin
  class AdminImageDiv < HtmlGrid::Div
    def image(artobject, url)
      img = HtmlGrid::Image.new('artobject_image', artobject, @session, self)
      img.css_id = "artobject_image_#{artobject.artobject_id}"
      img.set_attribute('src', url)
      link = HtmlGrid::HttpLink.new(:url, artobject, @session, self)
      link.href  = artobject.url
      link.value = img
      link.set_attribute('target', '_blank')
      @value = artobject.url.empty? ? img : link
      img
    end

    def init
      super
      obj = @model.is_a?(DaVaz::Model::ArtObject) ? @model : @model.artobject
      return unless obj
      if obj.artobject_id
        url = DaVaz::Util::ImageHelper.image_url(obj.artobject_id, nil, true)
        image(obj, url)
      elsif obj.tmp_image_path
        image(obj, obj.tmp_image_url)
      end
    end
  end

  # @api admin
  # @api ajax
  class AdminAjaxImageDiv < HtmlGrid::Div
    def image(artobject, url)
      img = HtmlGrid::Image.new('artobject_image', artobject, @session, self)
      img.set_attribute('src', url)
      img.css_id = 'artobject_image'
      link = HtmlGrid::HttpLink.new(:url, artobject, @session, self)
      link.href  = artobject.url
      link.value = img
      link.set_attribute('target', '_blank')
      if artobject.url.empty?
        @value = img
      else
        @value = link
      end
      img
    end

    def init
      super
      artobject_id = @model.artobject_id
      if artobject_id
        url = DaVaz::Util::ImageHelper.image_url(artobject_id)
        image(@model, url)
      elsif @model.tmp_image_path
        image(@model, artobject.tmp_image_url)
      end
    end
  end

  # @api admin
  # @api ajax
  class AdminAjaxUploadImage < AdminImageDiv
    include HtmlGrid::TemplateMethods
  end

  # @api admin
  # @api ajax
  class AdminAjaxUploadImageForm < Form
    CSS_ID     = 'upload_image_form'
    EVENT      = :ajax_upload_image
    LABELS     = true
    FORM_NAME  = 'ajax_upload_image_form'
    TAG_METHOD = :multipart_form
    COMPONENTS = {
      [0, 0]    => :image_file,
      [1, 1]    => :submit,
      [1, 1, 1] => :delete_image
    }
    SYMBOL_MAP = {
      :image_file => HtmlGrid::InputFile
    }

    def hidden_fields(context)
      super << context.hidden('artobject_id', artobject(@model).artobject_id)
    end

    def init
      super
      @form_properties.update('name'     => 'ajax_upload_image_form')
      @form_properties.update('onsubmit' => <<-EOS.gsub(/(^\s*)|\n/, ''))
        (function(e) {
          e.preventDefault();
          form = document.forms.ajax_upload_image_form;
          if (form.image_file.value != '') {
            submitForm(
              form
            , 'artobject_image_#{artobject(@model).artobject_id}'
            , 'upload_image_form'
            , true
            );
          }
          return false;
        })(event);
      EOS
    end

    def delete_image(model)
      input = HtmlGrid::Input.new(:delete_image, model, @session, self)
      input.value = @lookandfeel.lookup(:delete_image)
      input.set_attribute('type', 'button')
      url = @lookandfeel.event_url(:admin, :ajax_delete_image, [
        [:artobject_id, artobject(model).artobject_id]
      ])
      input.set_attribute('onclick', <<~EOS.gsub(/(^\s*)|\n/, ''))
        (function(e) {
          e.preventDefault();
          if (confirm('#{@lookandfeel.lookup(:ask_for_image_deletion)}')) {
            deleteImage(
              '#{url}'
            , 'artobject_image_#{artobject(model).artobject_id}'
            );
          }
        })(event);
      EOS
      input
    end

    def artobject(model)
      model.respond_to?(:artobject) ? model.artobject : model
    end
  end
end
