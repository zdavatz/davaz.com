require 'rclconf'
require 'davaz'
require 'drb/drb'

module DaVaz
  project_root = File.expand_path('../..', File.dirname(__FILE__))
  config_file  = File.join(project_root, 'etc', 'config.yml')
  defaults = {
    'config'      => config_file,
    'environment' => 'development',
    # use autologin is only for debugging purposes
    'autologin'  => false,
    'currencies' =>  {
      'USD'  => 'CHF',
      'Euro' => 'CHF',
    },
    'log_pattern'             => File.join(Dir.pwd, 'log','/%Y/%m/%d/davaz_log'),
    'server_port'             => nil,
    'db_manager'              => nil,
    'server_name'             => 'localhost',
    'server_uri'              => 'druby://localhost:9998',
    'document_root'           => File.expand_path('doc', project_root),
    'project_root'            => project_root,
    'run_updater'             => true,
    'dojo_debug'              => false,
    'large_image_width'       => '360px',
    'medium_image_width'      => '180px',
    'show_image_height'       => '280px',
    'small_image_width'       => '100px',
    'uploads_dir'             => 'resources/uploads',
    'tmp_images_path'         => 'uploads/tmp/images',
    'upload_images_path'      => 'uploads/images',
    # ticker
    'ticker_component_width'  => '180',
    'ticker_component_height' => '180',
    # yus
    'yus_domain' => 'com.davaz',
    'yus_server' => nil,
    'yus_uri'    => 'drbssl://localhost:9997',
    :colors => {
      :articles         => '#6d6dff',
      :carpets          => '#ff6c0d',
      :design           => '#FF6600',
      :drawings         => '#74ba7c',
      :exhibitions      => '#f1a309',
      :gallery          => '#f1171d',
      :lectures         => '#6d3d0c',
      :movies           => '#7a8a99',
      :multiples        => '#ce3dff',
      :paintings        => '#c60c6d',
      :photos           => '#39cece',
      :schnitzenthesen  => '#9eff0c',
    },
    # smtp
    :mailer => {
      :from   => '"Shop" <shop@example.org>',
      :to     => %w[],
      :server => '',
      :domain => 'example.org',
      :port   => 587,
      :auth   => 'plain',
      :user   => '',
      :pass   => '',
    }
  }

  # NOTE
  # RCLConf returns a hash which holds keys as String
  config = RCLConf::RCLConf.new(ARGV, defaults)
  config.load(config.config)
  @config = config
end
