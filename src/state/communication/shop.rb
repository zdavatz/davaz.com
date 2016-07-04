#!/usr/bin/env ruby
# State::Communication::Shop -- davaz.com -- 19.09.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/communication/shop'
require 'view/art_object'
require 'net/smtp'

module DAVAZ
	module State
		module Communication
class AjaxShop < SBSM::State
	VOLATILE = true
	VIEW = View::Communication::ShoppingCart
	def init
		artobject_id = @session.user_input(:artobject_id)
		count = @session.user_input(:count).to_i
		if(count == 0)
			@session[:cart_items].delete_if { |old_item| 
				old_item.artobject_id == artobject_id
			}
		else
			items = @session[:cart_items].select { |item| 
				item.artobject_id == artobject_id	
			}
			if(items.empty?)
				new_item = @session.load_shop_item(artobject_id)
				new_item.count = count
				@session[:cart_items].push(new_item)
			else
				items.first.count = @session.user_input(:count)
			end
		end
	end
end
class ShopArtObject < State::Global 
	VIEW = View::ShopArtObject 
	def init
		artobject_id = @session.user_input(:artobject_id)
		artgroup_id = @session.user_input(:artgroup_id)
		@model = OpenStruct.new
		@model.artobjects = @session.load_artgroup_artobjects(artgroup_id)
		@model.artobjects.delete_if { |artobject| 
			artobject.price == '0' || \
			artobject.price == ''	|| \
			artobject.price == nil 
		}
		object = @model.artobjects.find { |artobject| 
			artobject.artobject_id == artobject_id
		} 
		@model.artobject = object
	end
end
class Shop < State::Communication::Global
	VIEW = View::Communication::Shop
	def init
		@session[:cart_items] ||= []
		@model = OpenStruct.new
		@model.items = @session.app.load_shop_items
		@model.artgroups = @session.app.load_shop_artgroups
	end
	def remove_all_items
		@session[:cart_items] = []
		#State::Communication::Shop.new(@session, @model)
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
			State::Communication::ShopThanks.new(@session, @model)
		else
			self
		end
	end
	def send_mail(mandatory, hash)
		lookandfeel = @session.lookandfeel
		recipients = DAVAZ.config.recipients.dup.push(hash[:email])
    outgoing = Mail.new do
      content_type 'text/plain; charset=UTF-8'
      to           recipients
      from         DAVAZ.config.mail_from
      subject      'Bestellung von davaz.com'
    end
		address = mandatory.collect { |key|
			"#{lookandfeel.lookup(key)}: #{hash[key].to_s}"
		}
		orders = []
		total = 0
		@session[:cart_items].each { |item| 
			subtotal = (item.count * item.price.to_i)
			total += subtotal
			str = <<-EOS
#{item.count.to_s} x #{item.title.ljust(15)} (#{item.artgroup_id}): CHF #{subtotal}.-
			EOS
			orders.push(str)
		}
		orders.push("TOTAL: #{total}.-")
		parts = [
			@session.lookandfeel.lookup(:shop_mail_salut),
			address.join("\n"),
			orders.join("\n"),
			@session.lookandfeel.lookup(:shop_mail_bye),
		]
    outgoing.body = parts.join("\n\n")
    outgoing.date = Time.now
		Net::SMTP.start(DAVAZ.config.smtp_server) { |smtp|
			smtp.sendmail(outgoing.encoded, DAVAZ.config.smtp_from, recipients)
		}
		@session.infos.push(:i_order_sent)
	end
end
		end
	end
end
