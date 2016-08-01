#!/usr/bin/env ruby
# View::MailLink -- davaz.com -- 11.05.2006 -- mhuggler@ywesee.com

require 'htmlgrid/urllink'

module DaVaz
	module View
		class MailLink < HtmlGrid::MailLink
			def mailto=(email)
				self.href = "mailto:#{email}"
			end
		end
	end
end
