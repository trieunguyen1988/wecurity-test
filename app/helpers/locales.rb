class LocalesHelpers
    def initialize()
        localeDir = File.expand_path('../../../locales', __FILE__)
        I18n.load_path += Dir[File.join(localeDir, '*.yml').to_s]
    end

    def get_locale
        @locale
    end

    def set_locale(locale)
        I18n.locale = @locale.to_s
      end

    def t(*args)
        I18n.t(*args)
    end
end