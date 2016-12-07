# Simplecov must loaded as first file
require 'simplecov'
SimpleCov.start do
  command_name 'Watir-' + File.basename($0, '.rb')
  filters.clear # This will remove the :root_filter and :bundler_filter that come via simplecov's defaults
  add_filter "/test/"
  add_filter "/gems/"
  add_filter do |src|
    !(src.filename =~ /^#{SimpleCov.root}/) unless src.filename =~ /sbsm/
  end
  add_group "sbsm", "sbsm"
  add_group "davaz", "davaz.com"
  add_group "Long files" do |src_file|
    src_file.lines.count > 100
  end
end unless File.basename($0, '.rb').eql?('rake')
