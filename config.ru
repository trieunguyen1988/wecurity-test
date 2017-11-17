require 'sinatra/base'
require 'i18n'
require 'logger'
require 'sinatra/logger'
require "sinatra/cookies"
require "bcrypt"
require "./app/controllers/application_controller.rb"
require "./app/controllers/admin_controller.rb"
require "./app/controllers/exam_controller.rb"
require "./app/controllers/website_controller.rb"

require "./app/helpers/admin_helper.rb"

require "./app/models/exam_model.rb"
require "./app/models/option_model.rb"
require "./app/models/question_model.rb"
require "./app/models/user_model.rb"

# Dir.glob('./app/{models,helpers,controllers}/*.rb').each { |file| require file }

map "/public" do
    run Rack::Directory.new("./public")
end

map '/exam' do 
    run ExamController
end

map '/' do
    run WebsiteController
end

map '/admin' do
    run AdminController
end