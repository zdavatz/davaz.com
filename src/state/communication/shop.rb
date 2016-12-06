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
        if @session[:cart_items]
          SBSM.info "AjaxShop cart_items #{@session[:cart_items].inspect}  @session #{@session.object_id}"
        else
          SBSM.info "AjaxShop no cart_items found @session #{@session.object_id}"
        end
        count = @session.user_input(:count).to_i
        if count == 0
          @session[:cart_items].delete_if { |old_item|
            old_item.artobject_id == artobject_id
          }
        else
          @session[:cart_items] ||= []
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
        SBSM.debug "Shop: cart_items There are #{@session[:cart_items] ? @session[:cart_items].size : 'nil'} @session[:cart_items] @session #{@session.object_id}"
        @model = OpenStruct.new
        @model.items = @session.app.load_shop_items
        SBSM.debug "Shop: cart_items There are #{@model.items  ? @model.items .size : 'nil' } @model.items  @session #{@session.object_id}"
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
          SBSM.info "deliver articles #{hash}"
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

      def send_mail(mandatory, hash)
        config = DaVaz.config.mailer
        SBSM.info "config.mailer is  #{config}"
        address = mandatory.collect do |key|
          "#{@session.lookandfeel.lookup(key)}: #{hash[key].to_s}"
        end
        total = 0
        orders = @session[:cart_items].map do |item|
          subtotal = (item.count * item.price.to_i)
          total += subtotal
          <<~EOS.gsub(/\n/, '')
            #{item.count.to_s} x #{item.title.ljust(15)}
             (#{item.artgroup_id}): CHF #{subtotal}.\-
          EOS
             end
        orders.push("TOTAL: #{total}.\-")
        confirmation = [ @session.lookandfeel.lookup(:shop_mail_salut),
                         '',
                         address.join("\n"),
                         '',
                         orders.join("\n"),
                         '',
                         @session.lookandfeel.lookup(:shop_mail_bye),
                         '',
                         "Ref ##{SecureRandom.urlsafe_base64(8, true)}"
                       ].join("\n")
        Mail.defaults { delivery_method :test } if config['delivery_test']
        Mail.deliver do
          to hash[:email]
          from DaVaz.config.mailer['from']
          subject 'Bestellung von davaz.com.'
          html_part do
            content_type 'text/html; charset=UTF-8'
            confirmation
          end
        end
        SBSM.info "SentMail  #{hash[:email]} #{confirmation.size} bytes"
        @session.infos.push(:i_order_sent)
      end
    end
  end
end
