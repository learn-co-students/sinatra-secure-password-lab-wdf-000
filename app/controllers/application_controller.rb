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
      redirect "/login"
    else
      redirect "/failure"
    end
  end

  get '/account' do
    @user = User.find(session[:user_id])
    @session = session
    erb :account
  end


  get "/login" do
    erb :login
  end

  post "/login" do
    user = User.find_by(:username => params[:username])
		if user && user.authenticate(params[:password])
			session[:user_id] = user.id
			redirect "/success"
		else
			redirect "/failure"
		end
  end

  get "/success" do
    if logged_in?
      redirect '/account'
    else
      redirect "/login"
    end
  end

  get "/failure" do
    @session = session
    erb :failure
  end

  get "/logout" do
    session.clear
    redirect "/"
  end

  patch "/deposit" do
    session[:withdraw_done] = false
    ##Todo: add a checkup on input that it's digits, not letters etc that are in the input
    deposit = params["deposit"].to_f
    user = User.find(session[:user_id])
    new_balance = user.balance + deposit
    @user = user.update_attribute(:balance, new_balance)
    session[:deposit_succesful] = true
    redirect '/account'
  end

  patch "/withdrawal" do
    session[:deposit_succesful] = false
    ##Todo: add a checkup on input that it's digits, not letters etc that are in the input
    withdrawal = params["withdrawal"].to_f
    user = User.find(session[:user_id])
    if user.balance >= withdrawal
      new_balance = user.balance - withdrawal
      @user = user.update_attribute(:balance, new_balance)
      session[:withdraw_done] = true
      redirect '/account'
    else
      session[:over_drawn] = true
      session[:withdraw_done] = false
      redirect '/failure'
    end
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
