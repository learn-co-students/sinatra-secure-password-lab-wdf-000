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
    user = User.new(:username => params[:username], :password => params[:password])
    if user.save
      user.balance = 0
      user.save
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

  # THIS ISNT WORKING!!
  patch "/bal_update" do
    @user = current_user
    if params[:coins] == "add"
      new_bal = @user.balance + params[:user][:amount].to_f
      @user.update(balance: new_bal)
    elsif params[:coins] == "remove" && params[:user][:amount] > @user.balance
      session[:warning] = "Failure"
      redirect 't_failure'
    else
      new_bal = @user.balance - params[:user][:amount].to_f
      @user.update(balance: new_bal)
    end
    @user.save
    binding.pry
    redirect 'account'
  end

  get "/failure" do
    erb :failure
  end

  get '/t_failure' do
    @warning = session[:t_failure]
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
