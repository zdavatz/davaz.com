require 'htmlgrid/divcomposite'
require 'htmlgrid/link'

module DaVaz::View
  class AdminAjaxAddNewElementComposite < HtmlGrid::DivComposite
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
end
