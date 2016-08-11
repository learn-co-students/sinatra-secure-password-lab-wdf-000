require "./config/environment"
require "./app/models/user"
require 'pry'
class ApplicationController < Sinatra::Base

  configure do
    set :views, "app/views"
    enable :sessions
    set :session_secret, "password_security"
  end

  get "/" do
    erb :index
  end

  get "/signup" do
    erb :signup
  end

  post "/signup" do
    user = User.new(:username => params[:username], :password => params[:password], :balance => 0.0)
    if user.save
      redirect '/login'
    else
      redirect '/failure'
    end
  end

  get "/login" do
    erb :login
  end

  post "/login" do
    user = User.find_by(username: params[:username])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect '/account'
    else
      redirect '/failure'
    end
  end

  get "/account" do
    if logged_in?
      @user = current_user
      erb :account
    else
      redirect "/login"
    end
  end

  get '/edit' do
    if logged_in?
      @user = current_user
      erb :edit
    else
      redirect "/login"
    end
  end

  # Bonus code
  patch "/bal_update" do
    @user = current_user
    # have to set password explicitly to prevent transacton rollback!
    # this is due to current_user returning a field called password_digest NOT password!
    @user.password = @user.password_digest
    if params[:coins] == "add"
      @user.balance = @user.balance + params[:user][:amount].to_f
    elsif params[:coins] == "remove" && params[:user][:amount].to_f > @user.balance
      session[:warning] = "Failure"
      redirect 't_failure'
    else
      @user.balance = @user.balance - params[:user][:amount].to_f
    end
    @user.save
    redirect 'account'
  end

  get "/failure" do
    erb :failure
  end

  # Bonus code
  get '/t_failure' do
    @user = current_user
    @warning = session[:warning]
    erb :account
  end

  get "/logout" do
    session.clear
    redirect "/"
  end

  helpers do
    def logged_in?
      !!session[:user_id]
    end

    def current_user
      User.find(session[:user_id])
    end
  end

end
