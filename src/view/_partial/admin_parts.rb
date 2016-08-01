require 'htmlgrid/template'
require 'view/_partial/form'

module DaVaz::View
  module Admin
    class ImageDiv < HtmlGrid::Div
      def image(artobject, url)
        img = HtmlGrid::Image.new('artobject_image', artobject, @session, self)
        img.css_id = 'artobject_image'
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
        obj = @model.artobject
        if obj.artobject_id
          url = DaVaz::Util::ImageHelper.image_url(obj.artobject_id, nil, true)
          image(obj, url)
        elsif obj.tmp_image_path
          image(obj, obj.tmp_image_url)
        end
      end
    end
  end
end
