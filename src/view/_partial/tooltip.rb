require 'htmlgrid/divcomposite'
require 'htmlgrid/image'
require 'view/_partial/textblock'

module DaVaz::View
  class TooltipComposite < HtmlGrid::DivComposite
    COMPONENTS = {
      [ 0, 0] => :image,
      [ 0, 1] => :title,
      [ 0, 2] => :text,
      [ 0, 3] => :author,
    }
    CSS_MAP = {
      0 => 'tooltip-image',
      1 => 'tooltip-title',
      2 => 'tooltip-text',
      3 => 'tooltip-author',
    }

    def image(model)
      artobject_id = model.artobject_id
      img = HtmlGrid::Image.new(artobject_id, model, @session, self)
      img.css_class = 'image-tooltip-image'
      if DaVaz::Util::ImageHelper.has_image?(artobject_id)
        url = DaVaz::Util::ImageHelper.image_url(artobject_id)
        img.set_attribute('src', url)
      else
        img.set_attribute('src', '')
      end
      img
    end
  end

  class Tooltip < HtmlGrid::DivComposite
    CSS_CLASS = 'tooltip-container'
    COMPONENTS = {
      [ 0, 0] =>  TooltipComposite,
    }
    HTTP_HEADERS = {
      'Content-Type' => 'text/html;charset=UTF-8'
    }
  end

  # @api admin
  class AdminTooltipComposite < TooltipComposite
    def image(model)
      tooltip = model.artobjects.first
      artobject_id = tooltip.artobject_id
      if artobject_id && DaVaz::Util::ImageHelper.has_image?(artobject_id)
        img = HtmlGrid::Image.new(artobject_id, model, @session, self)
        url = DaVaz::Util::ImageHelper.image_url(artobject_id)
        img.set_attribute('src', url)
        img.css_class = 'image-tooltip-image'
        img
      else
        ''
      end
    end
  end

  # @api admin
  class AdminTooltip < Tooltip
    COMPONENTS = {
      [ 0, 0] =>  AdminTooltipComposite,
    }
  end
end
