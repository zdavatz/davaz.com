#!/usr/bin/env ruby
# Updater -- davaz.com -- 10.05.2006 -- mhuggler@ywesee.com

require 'logger'
require 'net/http'

module DAVAZ
	module Util
		class Updater
			def initialize(app)
				@app = app
				log_path = File.join(DAVAZ.config.project_root, "log")
				log_file = File.join(log_path, 'update_log')
				@logger = Logger.new(log_file)
			end
			def run
				update_exchange_rate
			end
			def update_exchange_rate
				curr_updater = CurrencyUpdater.new(@app)
				affected_rows = curr_updater.run
				if(affected_rows.include?(0))
					number = affected_rows.select { |i| i == 0 }.size	
					if(number == 1)
						info = "#{number} Currency was not updated on:"	
					else
						info = "#{number} Currencies were not updated on:"	
					end
				else
					info = "Currencies updated on:"	
				end
				@logger.add(Logger::INFO, info+"#{Time.now}", "ExchangeRate")
			end
		end
		class CurrencyUpdater
			def initialize(app)
				@app = app 
			end
			def run
				curr = DAVAZ.config.currencies.dup
				affected_rows = []
				curr.each { |target, origin| 
					affected_rows.push(update_conversion(origin, target))
				}
				affected_rows
			end
			def extract_conversion(html)
				if(match = /1\s+[^<>=]+=\s+(\d+\.\d+)/.match(html))
					match[1]
				end
			end
			def get_conversion(origin, target)
				extract_conversion(get_html(origin, target)).to_f
			end
			def get_html(origin, target)
				Net::HTTP.start('www.google.com') { |session| 
					session.get("/search?q=1+#{origin}+in+#{target}").body
				}
			end
			def update_conversion(origin, target)
				rate = get_conversion(origin, target)
				@app.db_manager.update_currency(origin, target, rate)	
			end
		end
	end
end
