require 'sinatra/base'

class ApplicationController < Sinatra::Base
    
    # Load cookies
    helpers Sinatra::Cookies

    set :views, File.expand_path('../../views', __FILE__)
    set :locales, %w[en vi]
    set :default_locale, 'en'
    set :locale_pattern, /^\/?(#{Regexp.union(settings.locales)})(\/.+)$/
    enable :sessions
    set :session_secret, "328479283uf923fu8932fu923uf9832f23f232"

    # Cookies options
    set :cookies_domain, "localhost"
    set :cookies_path, "/"
    set :cookies_expires, Time.now + 86400000

    # Point options
    set :point_passed, 4

    # Setting for administrator
    set :admin_name, "Administrator"
    set :admin_username, "admin"
    set :admin_password_salt, "$2a$10$2ObaFYKERzNH36oNpgEO8u"
    set :admin_password_hash, "$2a$10$2ObaFYKERzNH36oNpgEO8uhJ2xZhixbqyHfHfodGhCu/8SYOV38wK"

    configure do
        logDir = File.expand_path('../../../log', __FILE__)
        LOGGER   = Logger.new(File.join(logDir, "#{settings.environment}.log"))
        
        file = File.new("#{logDir}/#{settings.environment}.log", 'a+')
        file.sync = true
        use Rack::CommonLogger, file
    end

    # We're going to load the paths to locale files,
    localeDir = File.expand_path('../../../locales', __FILE__)
    I18n.load_path += Dir[File.join(localeDir, '*.yml').to_s]

    before do
        session[:locale] = params[:locale] if params[:locale]
        if session[:locale].to_s.empty?
            session[:locale] = settings.default_locale
        end
        LOGGER.info "BBBBBBBB - Locale value: " + session[:locale]

        request.path_info = $1, $2 if request.path_info =~ settings.locale_pattern
        @locale = session[:locale]
        set_locale(@locale)

        @user_data = get_user_data

        # Remove params not need
        if params.has_key? 'captures'
            params.delete 'captures'
        end
        # cookies.delete(:user_data)
    end

    helpers do
        def get_locale
            @locale
        end

        def set_locale(locale)
            I18n.locale = @locale.to_s
          end

        def t(*args)
            I18n.t(*args)
        end

        # Get user data from cookies
        def get_user_data
            user_data = nil
            
            if cookies.has_key?(:user_data) && cookies[:user_data].to_s != ''
                user_data = string_to_hash(cookies[:user_data])
            end
            user_data
        end

        def check_user
            user_data = get_user_data
            if user_data.nil?
              redirect '/'
            end
        end

        #Convert string to hash
        def string_to_hash(str)
            hash_data = eval(str)
            hash_data
        end

    end

    not_found{ erb :not_found }
end