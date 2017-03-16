require 'i18n'
require 'i18n/backend/asf'

I18n::Backend::Simple.send(:include, I18n::Backend::ASF)
