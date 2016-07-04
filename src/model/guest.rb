#!/usr/bin/env ruby
# Model::Guest -- davaz.com -- 12.09.2005 -- mhuggler@ywesee.com

module DAVAZ
  module Model
    class Guest
      attr_accessor :guest_id, :name, :email
      attr_accessor :date, :text, :city, :country
      def date_gb
        Date.parse(@date).strftime("%d.%m.%Y")
      end
      def messagetxt
        @text
      end
    end
  end
end
