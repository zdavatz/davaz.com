require 'mail'
require 'securerandom'
require 'state/predefine'
require 'view/communication/shop'
require 'view/_partial/art_object'

module DaVaz::State
  module Communication
    class AjaxShop < SBSM::State
      VOLATILE = true
      VIEW     = DaVaz::View::Communication::ShoppingCart

      def init
        artobject_id = @session.user_input(:artobject_id)
        count = @session.user_input(:count).to_i
        if count == 0
          @session[:cart_items].delete_if { |old_item|
            old_item.artobject_id == artobject_id
          }
        else
          items = @session[:cart_items].select { |item|
            item.artobject_id == artobject_id
          }
          if items.empty?
            new_item = @session.load_shop_item(artobject_id)
            new_item.count = count
            @session[:cart_items].push(new_item)
          else
            items.first.count = @session.user_input(:count)
          end
        end
      end
    end

    class ShopArtObject < Global
      VIEW = DaVaz::View::ShopArtObject

      def init
        artobject_id = @session.user_input(:artobject_id)
        artgroup_id = @session.user_input(:artgroup_id)
        @model = OpenStruct.new
        @model.artobjects = @session.load_artgroup_artobjects(artgroup_id)
        @model.artobjects.delete_if { |artobject|
          artobject.price == '0' || \
          artobject.price == ''  || \
          artobject.price == nil
        }
        object = @model.artobjects.find { |artobject|
          artobject.artobject_id == artobject_id
        }
        @model.artobject = object
      end
    end

    class Shop < Global
      VIEW = DaVaz::View::Communication::Shop
      options = {
          :address => DaVaz.config.mailer['server'],
          :port => DaVaz.config.mailer['port'],
          :domain => DaVaz.config.mailer['domain'],
          :user_name => DaVaz.config.mailer['user'],
          :password => DaVaz.config.mailer['pass'],
          :authentication => DaVaz.config.mailer['auth'],
          :enable_starttls_auto => true,
        }
      Mail.defaults do
        delivery_method :smtp, options
      end

      def init
        @session[:cart_items] ||= []
        @model = OpenStruct.new
        @model.items = @session.app.load_shop_items
        @model.artgroups = @session.app.load_shop_artgroups
      end

      def remove_all_items
        @session[:cart_items] = []
        self
      end

      def send_order
        mandatory = [ :name, :surname, :street, :postal_code, :city,
          :country, :email ]
        keys = mandatory.dup.push(:article)
        hash = user_input(keys, mandatory)
        unless error?
          hash[:article].each { |artobject_id, count|
            unless count == ""
              item = @session.load_shop_item(artobject_id)
              item.count = count.to_i
            end
          }
          send_mail(mandatory, hash)
          @session[:cart_items] = []
          ShopThanks.new(@session, @model)
        else
          self
        end
      end

      # @todo
      #   Add support for testing
      def send_mail(mandatory, hash)
        config = DaVaz.config.mailer
        address = mandatory.collect { |key|
          "#{@session.lookandfeel.lookup(key)}: #{hash[key].to_s}"
        }
        total = 0
        orders = @session[:cart_items].map { |item|
          subtotal = (item.count * item.price.to_i)
          total += subtotal
          <<~EOS.gsub(/\n/, '')
            #{item.count.to_s} x #{item.title.ljust(15)}
             (#{item.artgroup_id}): CHF #{subtotal}.\-
          EOS
        }
        orders.push("TOTAL: #{total}.\-")
        Mail.deliver do
          to hash[:email]
          from DaVaz.config.mailer['from']
          subject 'Bestellung von davaz.com.'
          html_part do
          content_type 'text/html; charset=UTF-8'
            [ @session.lookandfeel.lookup(:shop_mail_salut),
              '',
              address.join("\n"),
              '',
              orders.join("\n"),
              '',
              @session.lookandfeel.lookup(:shop_mail_bye),
              '',
              "Ref ##{SecureRandom.urlsafe_base64(8, true)}"
            ].join("\n")
          end
        end
        SBSM.info "SentMail  #{body.size}"
        @session.infos.push(:i_order_sent)
      end
    end
  end
end
