class WebsiteController < ApplicationController
    # helpers LocalesHelpers
  
    get '/' do
      unless get_user_data.nil?
        redirect '/exam'
      end
      erb :"user/home", layout: :user_layout
    end

    get '/set-language/:lang' do
      LOGGER.info "Language = " + params[:lang]
      unless params[:lang].to_s.empty?
        session[:locale] = params[:lang].to_s
      end
      redirect back
    end
  
    get '/info' do
      @title = "Input information"
      erb :"user/info", layout: :user_layout
    end

    post '/save_user_info' do
      LOGGER.debug "Params: " + params.to_s
      @user_error = nil
      if params["fullname"].to_s.empty?
        LOGGER.debug "Full name is empty "
        @user_error = t 'error.fullname-require', locale: get_locale
        erb :"user/home", layout: :user_layout
      else
        user = {
          'fullname' => params['fullname'],
          'company' => params['company'], 
          'project' => params['project']
        }
        cookies[:user_data] = user
        LOGGER.debug "User cookies: " + cookies[:user_data].to_s

        redirect '/exam'
      end
    end

    get '/logout' do
      cookies.clear
      session.clear
      redirect '/'
    end

end