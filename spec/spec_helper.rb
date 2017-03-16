ROOT_DIR = Pathname.new(File.expand_path("../../", __FILE__))
$:<< ROOT_DIR.join("lib")

require 'awesome_print'
require 'i18n-asf'

# Enable i18n fallbacks
require "i18n/backend/fallbacks"
I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end
