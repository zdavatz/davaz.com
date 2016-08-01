require 'htmlgrid/div'
require 'htmlgrid/divform'
require 'htmlgrid/span'
require 'htmlgrid/errormessage'
require 'htmlgrid/button'
require 'htmlgrid/link'
require 'htmlgrid/input'
require 'view/_partial/list'
require 'view/_partial/formlist'
require 'view/template'

module DaVaz::View
  module Communication
    class ShopTitle < HtmlGrid::Div
      CSS_CLASS = 'table-title'

      def init
        super
        span = HtmlGrid::Span.new(model, @session, self)
        span.css_class = 'table-title'
        span.value     = @lookandfeel.lookup(:davaz_shop)
        @value = span
      end
    end

    class ShopList < List
      CSS_CLASS    = 'shop-list'
      STRIPED_BG   = false
      SORT_DEFAULT = :title
      COMPONENTS   = {
        [0, 0] => :input,
        [1, 0] => 'item_s',
        [2, 0] => :object_title,
        [3, 0] => :franks,
        [4, 0] => 'slash_divider',
        [5, 0] => :dollars,
        [6, 0] => 'slash_divider',
        [7, 0] => :euros
      }
      CSS_MAP = {
        [0, 0] => 'shop-input',
        [1, 0] => 'shop-item',
        [2, 0] => 'shop-name',
        [3, 0] => 'shop-price',
        [4, 0] => 'shop-divider',
        [5, 0] => 'shop-price',
        [6, 0] => 'shop-divider',
        [7, 0] => 'shop-price'
      }

      def compose_header(offset=[0,0])
        table_title = @model.first.artgroup
        @grid.add(table_title, 0, 0)
        @grid.add_tag('TH', 0, 0)
        @grid.set_colspan(0, 0, full_colspan)
        resolve_offset(offset, [0,1])
      end

      def input(model)
        name = "article[#{model.artobject_id}]"
        input = HtmlGrid::Input.new(name, model, @session, self)
        input.set_attribute('size', 1)
        input.css_id = name
        args = [
          [:artobject_id, model.artobject_id],
          [:count,        nil]
        ]
        url = @lookandfeel.event_url('communication', 'ajax_shop', args)
        script = "reloadShoppingCart('#{url}', this.value);"
        input.set_attribute('onBlur', script)
        input.set_attribute('name', name)
        in_cart = @session[:cart_items].select { |item|
          item.artobject_id == model.artobject_id
        }

        if in_cart.size == 1
          input.set_attribute('value', in_cart.first.count)
        end
        input
      end

      def object_title(model)
        link = HtmlGrid::Link.new(:artobject_link, model, @session, self)
        link.href  = @lookandfeel.event_url(:communication, :shop_art_object, [
          [:artgroup_id,  model.artgroup_id],
          [:artobject_id, model.artobject_id]
        ])
        link.value = model.title
        link
      end

      def franks(model)
        "CHF #{model.price}.-"
      end

      def dollars(model)
        "$ #{model.dollar_price}.-"
      end

      def euros(model)
        "&euro; #{model.euro_price}.-"
      end
    end

    class ShopFormAddress < Composite
      include HtmlGrid::ErrorMessage

      CSS_ID = 'shopping_address'
      LABELS = true
      DEFAULT_CLASS = HtmlGrid::InputText
      COMPONENTS = {
        [0, 0] => :name,
        [2, 0] => :surname,
        [0, 1] => :street,
        [0, 2] => :postal_code,
        [2, 2] => :city,
        [0, 3] => :country,
        [0, 4] => :email
      }

      def init
        super
        error_message
      end
    end

    class ShoppingCartList < List
      STRIPED_BG = false
      CSS_CLASS  = 'shopping-cart-list'
      COMPONENTS = {
        [0, 0] => :count,
        [1, 0] => 'times_divider',
        [2, 0] => :title,
        [3, 0] => 'a_divider',
        [4, 0] => :price,
        [5, 0] => 'equal_divider',
        [6, 0] => :subtotal,
        [7, 0] => :remove_item,
      }
      CSS_MAP = {
        [2, 0] => 'shopping-cart-title',
        [6, 0] => 'shopping-cart-subtotal'
      }

      def compose_header(offset=[0,0])
        table_title = @lookandfeel.lookup(:shopping_cart)
        @grid.add(table_title, 0, 0)
        @grid.add_tag('TH', 0, 0)
        @grid.set_colspan(0, 0, full_colspan)
        resolve_offset(offset, [0,1])
      end

      def compose_footer(matrix)
        @grid.add(@lookandfeel.lookup(:total), *matrix)
        @grid.add_attribute('class', 'shopping-cart-total-title', *matrix)
        matrix = resolve_offset(matrix, [4,0])
        franks = 0
        dollars = 0
        euros = 0
        model.each { |item|
          franks += item.count.to_i * item.price.to_i
          dollars += item.count.to_i * item.dollar_price.to_i
          euros += item.count.to_i * item.euro_price.to_i
        }
        total = "CHF #{franks}.- / $ #{dollars}.- / &euro; #{euros}.-"
        @grid.add(total, *matrix)
        @grid.set_colspan(*matrix.dup.push(3))
        @grid.add_attribute('class', 'shopping-cart-total', *matrix)
        unless @session[:cart_items].empty?
          link = HtmlGrid::Link.new(:remove_item, model, @session, self)
          link.value = @lookandfeel.lookup(:remove_all_items)
          event_url = @lookandfeel.event_url(:communication, :remove_all_items)
          link.href = event_url
          @grid.add(link, *resolve_offset(matrix, [3,0]))
        end
      end

      def price(model)
        "CHF #{model.price}.-"
      end

      def subtotal(model)
        "CHF #{model.count.to_i * model.price.to_i}.-"
      end

      def remove_item(model)
        link = HtmlGrid::Link.new(:remove_item, model, @session, self)
        link.value = @lookandfeel.lookup(:remove_item)
        link.href  = 'javascript:void(0)'
        url = @lookandfeel.event_url('communication', 'ajax_shop', [
          [:artobject_id, model.artobject_id],
          [:count,        0]
        ])
        link.set_attribute('onclick', <<~EOS)
          removeFromShoppingCart('#{url}', 'article[#{model.artobject_id}]');
        EOS
        link
      end
    end

    class ShoppingCart < Composite
      CSS_ID = 'shopping_cart'
      COMPONENTS = {
        [0, 0] => :shopping_cart_list,
      }

      def shopping_cart_list(model)
        ShoppingCartList.new(@session[:cart_items], @session, self)
      end
    end

    class ShopForm < HtmlGrid::DivForm
      FORM_ID = 'shop_form'
      EVENT   = :send_order
      COMPONENTS = {
        [0, 0] => :item_list,
        [0, 1] => ShopFormAddress,
        [0, 2] => ShoppingCart,
        [0, 3] => :submit
      }
      CSS_ID_MAP = {
        1 => 'shopping_address',
        2 => 'shopping_cart',
        3 => 'shopping_submit'
      }

      def item_list(model)
        tables = []
        @model.artgroups.each { |artgroup|
          artgroup_items = @model.items.select { |item|
            item.artgroup_id == artgroup.artgroup_id
          }
          unless artgroup_items.empty?
            tables.push(ShopList.new(artgroup_items, @session, self))
          end
        }
        tables
      end

      def submit(model)
        button = HtmlGrid::Button.new(:order_item, model, @session, self)
        button.value     = @lookandfeel.lookup(:order_items)
        button.css_class = 'order-item'
        button.attributes['type'] = 'submit'
        button
      end
    end

    class ShopComposite < HtmlGrid::DivComposite
      CSS_CLASS  = 'content'
      COMPONENTS = {
        [0,0] => ShopTitle,
        [1,0] => ShopForm
      }

      def init
        if @session.error?
          self.onload = "jumpTo('shopping-address');"
        end
        super
      end
    end

    class Shop < CommunicationTemplate
      CONTENT = ShopComposite
    end
  end
end
