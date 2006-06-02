#!/usr/bin/env ruby
# DavazConfig -- davaz.com 18.07.2005 -- mhuggler@ywesee.com

# Do not require any Application-Internals in this file

module DAVAZ
	SERVER_NAME = 'www.davaz.com'
	SERVER_URI = "druby://localhost:9998"
	PROJECT_ROOT = File.expand_path('../..', File.dirname(__FILE__))
	DOCUMENT_ROOT = File.join(PROJECT_ROOT, 'doc')
	SMTP_SERVER = 'mail.ywesee.com'
	MAIL_FROM = '"markus.huggler" <mhuggler@ywesee.com>'
	SMTP_FROM = 'mhuggler@ywesee.com'
	RECIPIENTS = [ 'mhuggler@ywesee.com' ]
	TICKER_COMPONENT_WIDTH = '180'
	TICKER_COMPONENT_HEIGHT = '180'
	SMALL_IMAGE_WIDTH = '100px'
	MEDIUM_IMAGE_WIDTH = '180px'
	LARGE_IMAGE_WIDTH = '360px'
	SLIDESHOW_IMAGE_HEIGHT = '280px'
	CURRENCIES = {
		'USD'		=>	'CHF',
		'Euro'	=>	'CHF',
	}
	COLORS = {
		:articles			=>	'#6d6dff',		
		:carpets			=>	'#ff6c0d',		
		:design				=>	'#FF6600',		
		:drawings			=>	'#74ba7c',		
		:exhibitions	=>	'#f1a309',		
		:gallery			=>	'#f1171d',		
		:lectures			=>	'#6d3d0c',		
		:movies				=>	'#7a8a99',		
		:multiples		=>	'#ce3dff',		
		:paintings		=>	'#c60c6d',		
		:photos				=>	'#39cece',		
		:schnitzenthesen	=>	'#9eff0c',		
	}	
end
