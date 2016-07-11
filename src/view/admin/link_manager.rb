require 'htmlgrid/divform'

module DAVAZ
  module View
    module Admin
      class LinkTitle < HtmlGrid::DivComposite
        COMPONENTS = {
          [0, 0] => :word,
          [0, 1] => :remove_link,
        }
        CSS_MAP = {
          0 => 'links-list-link-word',
          1 => 'links-list-remove-link',
        }

        def remove_link(model)
          url = @lookandfeel.event_url(:admin, :ajax_delete_link, [
            [:link_id,      model.link_id],
            [:artobject_id, model.artobject_id]
          ])
          link = HtmlGrid::Link.new(:remove_link, model, @session , self)
          link.href = 'javascript:void(0)'
          link.set_attribute('class', 'links-list-add-image')
          link.set_attribute('onclick', <<~TGGL)
            toggleInnerHTML('link-manager', '#{url}');
          TGGL
          link
        end
      end

      class ImageBrowserContainer < HtmlGrid::Div
        def init
          super
          self.send(:css_id=, "image_browser_container_#{model.link_id}")
        end
      end

      class LinkComposite < HtmlGrid::DivComposite
        COMPONENTS = {
          [0, 0]    => LinkTitle,
          [0, 1]    => :choose_image,
          [1, 1]    => 'pipe_divider',
          [1, 1, 1] => :add_element,
          [0, 2]    => ImageBrowserContainer,
        }
        CSS_MAP = {
          0 => 'links-list-link',
          1 => 'links-list-add-element',
          3 => 'links-list-image',
        }

        def choose_image(model)
          url = @lookandfeel.event_url(:admin, :ajax_image_browser, [
            [:link_id, model.link_id],
            [:tags,    @session.user_input(:tags)]
          ])
          link = HtmlGrid::Link.new(:add_element, model, @session , self)
          link.href  = 'javascript:void(0)'
          link.value = @lookandfeel.lookup(:choose_image)
          link.set_attribute('onclick', <<~TGGL)
            toggleInnerHTML(
              'image_browser_container_#{model.link_id}', '#{url}');
          TGGL
          link
        end

        def add_element(model)
          args = [
          ]
          url = @lookandfeel.event_url(:admin, :new, [
            [:parent_link_id, model.link_id],
            [:table,          'displayelements'],
            [:breadcrumbs,    @session.update_breadcrumbs]
          ])
          link = HtmlGrid::Link.new(:add_element, model, @session , self)
          link.href = url
          link
        end
      end

      class LinksList < HtmlGrid::DivList
        COMPONENTS = {
          [0, 0] => LinkComposite,
        }

        def tag_attributes(idx)
          hash = super
          link = @model.at(idx)
          hash.store('id', "link_composite_#{link.link_id}")
          hash
        end
      end

      class AddLinkForm < HtmlGrid::DivForm
        EVENT  = :ajax_add_link
        LABELS = true
        COMPONENTS = {
          [0, 0] => :link_word,
          [1, 0] => :submit,
        }
        SYMBOL_MAP = {
          :link_word => HtmlGrid::Input,
        }

        def init
          super
          self.set_attribute('onsubmit', <<~SCRIPT)
            submitForm(this, 'link_manager', 'add_link_form', true);
            return false;
          SCRIPT
        end

        def hidden_fields(context)
          super
        end
      end

      class LinkManager < HtmlGrid::DivComposite
        CSS_ID = 'links_list_container'
        COMPONENTS = {
          [0, 0] => AddLinkForm,
          [0, 1] => component(LinksList, :links),
        }
        CSS_ID_MAP = {
          0 => 'add_link_form',
        }
      end
    end
  end
end
