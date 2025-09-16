# encoding: utf-8

Rozario::App.controllers :feedback do

  # https://stackoverflow.com/questions/21262254/what-captcha-for-sinatra

  before do
    require 'yaml'
    @redis_enable = false
    redis_settings = YAML::load_file("config/redis.yml")
    REDIS = Redis.new(redis_settings['test'])
  end

  get :index do

    @canonical = "https://#{@subdomain.url != 'murmansk' ? "#{@subdomain.url}.#{CURRENT_DOMAIN}" : CURRENT_DOMAIN}/comment"

    #@comments = Comment.all(:order => 'created_at desc')
    #get_seo_data('comments', nil, true)
    #render 'comment/index'

    puts "get :index do comment.rb"
    if REDIS.get @subdomain.url + ':feedback' && @redis_enable; REDIS.get @subdomain.url + ':feedback'
    else
      @comments = Comment.all(:order => 'created_at desc')
      get_seo_data('comments', nil, true)
      page = render 'comment/index'; REDIS.setnx @subdomain.url + ':feedback', page; page
    end
  end

  post :submit do
    recaptcha_token = params[:'g-recaptcha-response']
    secret_key = ENV['RECAPTCHA_V3_SECRET_KEY_2']
    max_score = 0.5 # Usually value: 0.5 (Probability that the user is a human and not a robot)
    response = Net::HTTP.post_form(
      URI.parse('https://www.google.com/recaptcha/api/siteverify'), {
        'secret' => secret_key,
        'response'   => recaptcha_token
      }
    )
    result = JSON.parse(response.body)
    if result['success'] && result['score'].to_f >= max_score then
      if params[:rating].nil? then
        rating = '0'
        flash[:error] = 'Ошибка, установите оценку'
      else
        rating = params[:rating]
        msg_body = "Имя: #{params[:name]}\nЭл. почта: #{params[:email]}\nОтзыв: #{params[:msg]}\nОценка: #{rating}"
        email do
          from "no-reply@rozariofl.ru"
          to ENV['ORDER_EMAIL'].to_s
          subject "Отзыв с сайта"
          body msg_body
        end
        flash[:notice] = "Форма успешно отправлена!"
      end
    else
      if result['score'].to_f >= max_score then
        flash[:error] = "Ошибка верификации reCAPTCHA."
      else
        flash[:error] = "Ошибка верификации reCAPTCHA. Score: #{result['score']} #{result['error-codes']}"
      end
    end
    redirect back
  end

  get :test do
    @comments = Comment.all(:order => 'created_at desc')
    get_seo_data('comments', nil, true)
    page = render 'comment/indexxx'
  end

  post :index do
    if (!params[:name].empty? && !params[:msg].empty?)
      if verify_recaptcha
        if params[:rating].nil?
          rating = '0'
          flash[:error] = 'Ошибка, установите оценку'
        else
          rating = params[:rating]
          msg_body = "Имя: #{params[:name]}\nЭл. почта: #{params[:email]}\nОтзыв: #{params[:msg]}\nОценка: #{rating}"
          email do
            from "no-reply@rozariofl.ru"
            to ENV['ORDER_EMAIL'].to_s
            subject "Отзыв с сайта"
            body msg_body
          end
          flash[:notice] = 'Спасибо, Ваш отзыв отправлен на модерацию.'
        end
        #Comment_premod.create(name: params[:name], body: params[:msg], rating: params[:rating])
      else
        flash[:error] = 'Ошибка: неверный проверочный код..'
      end
    else
      flash[:error] = 'Пожалуйста, заполните все поля формы.'
    end
    redirect(url(:feedback, :index))
  end

  post :indexxx do
    puts "post :index do comment.rb"
    if (!params[:name].empty? && !params[:msg].empty?)
      if verify_recaptcha
        if params[:rating].nil?
          rating = '0'
          flash[:error] = 'Ошибка, установите оценку'
        else
          rating = params[:rating]
          msg_body = "Имя: #{params[:name]}\nЭл. почта: #{params[:email]}\nОтзыв: #{params[:msg]}\nОценка: #{rating}"
          email do
            from "no-reply@rozariofl.ru"
            to ENV['ORDER_EMAIL'].to_s
            subject "Отзыв с сайта"
            body msg_body
          end
          flash[:notice] = 'Спасибо, Ваш отзыв отправлен на модерацию.'
        end
        #Comment_premod.create(name: params[:name], body: params[:msg], rating: params[:rating])
      else
        flash[:error] = 'Ошибка: неверный проверочный код..'
      end
    else
      flash[:error] = 'Пожалуйста, заполните все поля формы.'
    end
    redirect(url(:feedback, :index))
  end
end

# Alias controller for backward compatibility with Nginx redirects
Rozario::App.controllers :comment do
  get :index do
    redirect url(:feedback, :index), 301
  end
end