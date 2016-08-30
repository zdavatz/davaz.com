require 'state/global'
require 'state/predefine'
require 'state/personal/init'
require 'state/communication/guestbook'
require 'state/communication/links'
require 'state/communication/news'
require 'state/communication/shop'

module DaVaz::State
  module Communication
    class Global < DaVaz::State::Global
      HOME_STATE = DaVaz::State::Personal::Init
      ZONE       = :communication
      EVENT_MAP  = {
        :guestbook    => Guestbook,
        :links        => Links,
        :news         => News,
        :send_order   => Shop,
        :shop_thanks  => ShopThanks,
        :shop         => Shop,
        :ajax_shop    => AjaxShop
      }
    end
  end
end
