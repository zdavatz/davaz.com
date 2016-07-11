source 'https://rubygems.org'

gem 'mysql2', '~> 0.4.4'
gem 'dbi', '~> 0.4.5'

gem 'rmagick', '~> 2.15.4'

gem 'rclconf', '1.0.0'
gem 'ftools', '0.0.0'

gem 'sbsm', '~> 1.2.8'
gem 'htmlgrid', '~> 1.1.1'
gem 'odba', '~> 1.1.0'

gem 'yus', '1.0.1'


# FIXME: following gems are needed as dependencies for yus
gem 'deprecated', '2.0.1'
gem 'needle', '1.3.0'
gem 'pg', '0.18.4'
gem 'dbd-pg', '0.3.9'


group :test do
  gem 'minitest', '~> 5.9'
  gem 'watir-webdriver'
  gem 'headless'
end

# NOTE: additional personal Gemfile.hack support for developer
#
# @example
#   bundle install         #=> loads .hack file will if it exists
#   HACK=no bundle install #=> ignores .hack file even if it exists
group :development, :test do
  if ENV['HACK'] !~ /\A(no|false)\z/i
    hack = File.expand_path('../Gemfile.hack', __FILE__)
    if File.exist?(hack)
      eval File.read(hack)
    end
  end
end
