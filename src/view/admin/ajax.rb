require 'htmlgrid/div'
require 'htmlgrid/image'
require 'htmlgrid/link'
require 'htmlgrid/divcomposite'
require 'view/_partial/form'

module DaVaz::View
  module Admin
    class AjaxAddNewElementComposite < HtmlGrid::DivComposite
      CSS_ID = 'add_new_element_composite'
      COMPONENTS = {
        [0, 1] => :add_new_element_link,
      }
      CSS_ID_MAP = {
        2 => 'add_new_element_form'
      }

      def add_new_element_link(model)
        link = HtmlGrid::Link.new(:new_element, model, @session, self)
        link.href = 'javascript:void(0)'
        url = @lookandfeel.event_url(@session.zone, :ajax_add_new_element)
        link.set_attribute('onclick', "addNewElement('#{url}');")
        link
      end
    end

    class AjaxUploadImage < ImageDiv
      include HtmlGrid::TemplateMethods
    end

    # @api admin
    class AjaxUploadImageForm < Form
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
        super << context.hidden('artobject_id', @model.artobject.artobject_id)
      end

      def init
        super
        self.set_attribute('onsubmit', <<-EOS.gsub(/(^\s*)|\n/, ''))
          if (this.image_file.value != '') {
            submitForm(
              this
            , 'artobject_image_#{@model.artobject.artobject_id}'
            , 'upload_image_form'
            , true
            );
          }
          return false;
        EOS
      end

      def delete_image(model)
        input = HtmlGrid::Input.new(:delete_image, model, @session, self)
        input.value = @lookandfeel.lookup(:delete_image)
        input.set_attribute('type', 'button')
        url = @lookandfeel.event_url(:admin, :ajax_delete_image, [
          [:artobject_id, model.artobject.artobject_id]
        ])
        input.set_attribute('onclick', <<~EOS.gsub(/(^\s*)|\n/, ''))
          if (confirm('#{@lookandfeel.lookup(:ask_for_image_deletion)}')) {
            deleteImage(
              '#{url}'
            , 'artobject_image_#{model.artobject.artgroup_id}'
            );
          }
        EOS
        input
      end
    end

    class AjaxImageDiv < HtmlGrid::Div
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
  end
end
