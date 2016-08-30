module DaVaz::Model
  class Guest
    attr_accessor :guest_id, :name, :email, :date, :text, :city, :country

    def date_gb
      begin
        unless @date.is_a?(Date)
          Date.parse(@date)
        else
          @date
        end
      rescue ArgumentError, TypeError
        Date.today
      end.strftime('%d.%m.%Y')
    end

    def messagetxt
      @text
    end
  end
end
