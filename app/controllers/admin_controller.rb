require "xmlsimple"
require "yaml/store"
require 'json'

require './app/models/exam_model'
require './app/models/option_model'
require './app/models/question_model'
require './app/helpers/admin_helper'

class AdminController < ApplicationController

    get '/' do
        unless check_admin_login
            redirect '/admin/login'
        end

        lang = get_locale
        exam = Exam.new
        @questions = exam.getQuestions(lang)

        options_json = {}
        unless @questions.nil?
            @questions.each do |question|
                opt = {}
                
                i = 0
                question.options.each do |option|
                    o = {}
                    o.store('id', option.id)
                    o.store('content', option.content)
                    opt.store(i, o)
                    i += 1
                end
                options_json.store(question.id, opt)
            end
        end
        @options_json = options_json.to_json

        erb :"admin/question_list", layout: :"admin/layout"
    end

    # show language list
    get '/choose-language' do
        unless check_admin_login
            redirect '/admin/login'
        end
        erb :"admin/set_language"
    end

    # Action set language
    get '/set-language/:lang' do
        unless check_admin_login
            redirect '/admin/login'
        end
        LOGGER.info "Refer = " + request.referrer
        
        unless params[:lang].to_s.empty?
          session[:locale] = params[:lang].to_s
        end

        refer_url = request.referrer
        if refer_url.include? "choose-language"
            redirect '/admin'
        else
            redirect back
        end
    end

    get '/login' do
        if check_admin_login
            redirect '/admin'
        end

        # @password_salt = BCrypt::Engine.generate_salt
        # @password_hash = BCrypt::Engine.hash_secret('lifull-techvn@#@', @password_salt)
        @error_message = '';
        erb :"admin/login"
    end

    post '/do_login' do
        username = params['username']
        password = params['password']

        @error_message = ''
        if username == settings.admin_username
            if settings.admin_password_hash == BCrypt::Engine.hash_secret(password, settings.admin_password_salt)
                session['admin_login'] = '1'
                session['admin_username'] = username
                session['admin_name'] = settings.admin_name
                redirect '/admin/choose-language'
            else
                @error_message = 'Username or Password is incorrect';
                erb :"admin/login"
            end
        else
            @error_message = 'Username or Password is incorrect';
            erb :"admin/login"
        end
    end

    get '/logout' do
        session.delete('admin_login')
        session.delete('admin_username')
        session.delete('admin_name')
        redirect '/admin/login'
    end

    # ===========================================
    # BEGIN add question
    # ===========================================
    # Show form add question
    get '/questions/create' do
        unless check_admin_login
            redirect '/admin/login'
        end

        lang = get_locale
        
        #old question
        exam = Exam.new
        old_questions = exam.getQuestions(lang)

        # Collect data
        max_id = _get_question_max_id(old_questions)
        @question_id = max_id + 1

        @errors = {}
        @data = {
            'content' => '',
            'answer' => '',
            'explain' => '',
            'option_1' => '',
            'option_2' => '',
            'option_3' => '',
            'option_4' => ''
        }
        erb :"admin/question_add", layout: :"admin/layout"
    end

    # Save question
    post '/questions/create' do
        unless check_admin_login
            redirect '/admin/login'
        end

        @errors = _validate_question

        if @errors.size > 0
            @data = params
            erb :"admin/question_add", layout: :"admin/layout"
        else
            lang = get_locale
            
            #old question
            exam = Exam.new
            old_questions = exam.getQuestions(lang)
    
            # Collect data
            max_id = _get_question_max_id(old_questions)
            option1 = Option.new(1,params['option_1'])
            option2 = Option.new(2,params['option_2'])
            option3 = Option.new(3,params['option_3'])
            option4 = Option.new(4,params['option_4'])
    
            question_inst = Question.new
            question_inst.id = (max_id + 1)
            question_inst.content = params['content']
            question_inst.answer = params['answer'].to_i
            question_inst.explain = params['explain']
            question_inst.options = [option1,option2,option3,option4]
    
            unless old_questions.nil?
                new_questions = old_questions.push(question_inst)
            else
                new_questions = [question_inst]
            end
    
            file_path = "./data/questions_" << lang << ".yml"
            store = YAML::Store.new file_path
            store.transaction do
                store["questions"] = new_questions
            end
    
            redirect '/admin'
        end
    end
    # ===========================================
    # END add question
    # ===========================================

    # ===========================================
    # BEGIN edit question
    # ===========================================
    get '/questions/edit/:id' do
        unless check_admin_login
            redirect '/admin/login'
        end

        @errors = {}
        @data = {
            'content' => '',
            'answer' => '',
            'explain' => '',
            'option_1' => '',
            'option_2' => '',
            'option_3' => '',
            'option_4' => ''
        }

        lang = get_locale
        #old question
        exam = Exam.new
        questions = exam.getQuestions(lang)
        question = exam.getQuestionInfo(questions, params[:id])

        @data = {
            'id' => question.id,
            'content' => question.content,
            'answer' => question.answer.to_s,
            'explain' => question.explain
        }

        question.options.each do |option|
            key = "option_" << option.id.to_s
            @data.store(key, option.content)
        end

        erb :"admin/question_edit", layout: :"admin/layout"
    end

    post '/questions/edit/:id' do
        unless check_admin_login
            redirect '/admin/login'
        end

        @errors = _validate_question

        if @errors.size > 0
            @data = params
            erb :"admin/question_edit", layout: :"admin/layout"
        else
            lang = get_locale
            
            #old question
            exam = Exam.new
            old_questions = exam.getQuestions(lang)
    
            # Collect data
            max_id = _get_question_max_id(old_questions)
            option1 = Option.new(1,params['option_1'])
            option2 = Option.new(2,params['option_2'])
            option3 = Option.new(3,params['option_3'])
            option4 = Option.new(4,params['option_4'])
    
            question_upd = Question.new
            question_upd.id = params['id'].to_i
            question_upd.content = params['content']
            question_upd.answer = params['answer'].to_i
            question_upd.explain = params['explain']
            question_upd.options = [option1,option2,option3,option4]
    
            new_questions = []
            old_questions.each do |question|
                if question.id.to_s == params[:id]
                    question = question_upd
                end
                new_questions.push(question)
            end
    
            file_path = "./data/questions_" << lang << ".yml"
            store = YAML::Store.new file_path
            store.transaction do
                store["questions"] = new_questions
            end
    
            redirect '/admin'
        end
    end
    # ===========================================
    # END edit question
    # ===========================================

    # ===========================================
    # BEGIN detail question
    # ===========================================
    get '/questions/detail/:id' do
        unless check_admin_login
            redirect '/admin/login'
        end

        @errors = {}
        @data = {
            'content' => '',
            'answer' => '',
            'explain' => '',
            'option_1' => '',
            'option_2' => '',
            'option_3' => '',
            'option_4' => ''
        }

        lang = get_locale
        #old question
        exam = Exam.new
        questions = exam.getQuestions(lang)
        question = exam.getQuestionInfo(questions, params[:id])

        @data = {
            'id' => question.id,
            'content' => question.content,
            'answer' => question.answer.to_s,
            'explain' => question.explain
        }

        question.options.each do |option|
            key = "option_" << option.id.to_s
            @data.store(key, option.content)
        end

        erb :"admin/question_detail", layout: :"admin/layout"
    end
    # ===========================================
    # END detail question
    # ===========================================

    # ===========================================
    # BEGIN delete question
    # ===========================================
    get '/questions/delete/:id' do
        unless check_admin_login
            redirect '/admin/login'
        end

        lang = get_locale
        #old question
        exam = Exam.new
        old_questions = exam.getQuestions(lang)
        
        new_questions = []
        old_questions.each do |question|
            if question.id.to_s != params[:id]
                new_questions.push(question)
            end
        end

        file_path = "./data/questions_" << lang << ".yml"
        store = YAML::Store.new file_path
        store.transaction do
            store["questions"] = new_questions
        end

        redirect '/admin'
    end
    # ===========================================
    # END delete question
    # ===========================================

    get '/questions/max_id' do
        lang = get_locale
        
        #old question
        exam = Exam.new
        old_questions = exam.getQuestions(lang)

        max_id = _get_question_max_id(old_questions)
        puts "Max_ID: " + max_id.to_s
    end

    private def _get_question_max_id(questions)
        max_id = 0
        unless questions.nil?
            questions.each do |question|
                if question.id.to_i > max_id
                    max_id = question.id.to_i
                end
            end
        end
        max_id
    end

    private def _validate_question
        errors = {}

        if params['content'].to_s.empty?
            msg = t 'admin.error-content-required', locale: get_locale
            errors.store('content', msg)
        end

        if params['option_1'].to_s.empty?
            msg = t 'admin.error-option-required', locale: get_locale
            errors.store('option_1', msg)
        end

        if params['option_2'].to_s.empty?
            msg = t 'admin.error-option-required', locale: get_locale
            errors.store('option_2', msg)
        end

        if params['option_3'].to_s.empty?
            msg = t 'admin.error-option-required', locale: get_locale
            errors.store('option_3', msg)
        end

        if params['option_4'].to_s.empty?
            msg = t 'admin.error-option-required', locale: get_locale
            errors.store('option_4', msg)
        end

        if params['answer'].to_s.empty?
            msg = t 'admin.error-answer-required', locale: get_locale
            errors.store('answer', msg)
        end

        if params['explain'].to_s.empty?
            msg = t 'admin.error-explain-required', locale: get_locale
            errors.store('explain', msg)
        end

        errors
    end
end