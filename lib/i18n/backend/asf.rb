require 'i18n/asf/processor'

module I18n
  module Backend
    module ASF

      protected

        def load_asf(filename)
          data = parse(filename)
          locale = data.delete("_locale") || get_locale_from_filename(filename)
          { locale => data }
        end

        def parse(filename)
          ::I18n::ASF::Processor.process_document File.read(filename)
        end

        def get_locale_from_filename(filename)
          ::File.basename(filename, '.asf').to_sym
        end

    end
  end
end