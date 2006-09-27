#!/usr/bin/env ruby
# @config -- davaz.com -- 26.09.2006 -- mhuggler@ywesee.com

require 'rclconf'
require 'drb/drb'

module DAVAZ 
  project_root = File.expand_path("../..", File.dirname(__FILE__)) 
  config_file = (File.join(project_root, 'etc', 'davaz.yml'))
  defaults = {
		#autologin to be removed, only for debugging purposes
		'autologin'								=>	false,
		'currencies'							=>	{
			'USD'		=>	'CHF',
			'Euro'	=>	'CHF',
		},
		'config'									=>	config_file,	
		'colors'									=> {
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
		},	
		'document_root'						=>	File.expand_path('doc', project_root),
		'dojo_debug'							=>	false,
		'large_image_width'				=>	'360px',
		'mail_from'								=>	'"markus.huggler" <mhuggler@ywesee.com>',
		'medium_image_width'			=>	'180px',
		'project_root'						=>	project_root,
		'recipients'							=>	[ 'mhuggler@ywesee.com' ],
		'run_updater'							=>	true,
		'server_name'							=>	'www.davaz.com',
		'server_uri'							=>	"druby://localhost:9998",
		'slideshow_image_height'	=>	'280px',
		'small_image_width'				=>	'100px',
		'smtp_server'							=>	'mail.ywesee.com',
		'smtp_from'								=>	'mhuggler@ywesee.com',
		'tmp_images_path'					=>	'uploads/tmp/images',
		'ticker_component_width'	=>	'180',
		'ticker_component_height' =>	'180',
		'upload_images_path'			=>	'uploads/images',
		'yus_domain'							=>	"com.davaz",
		'yus_uri'									=>	"drbssl://localhost:9997",
  }

  config = RCLConf::RCLConf.new(ARGV, defaults)
  config.load(config.config)
  @config = config

	@yus_server = DRb::DRbObject.new(nil, @config.yus_uri)
end
