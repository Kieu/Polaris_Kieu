class SessionsController < ApplicationController
  require 'feedzirra'
  def new
    @feed = Feedzirra::Feed.fetch_and_parse("http://vnexpress.net/rss/gl/trang-chu.rss")
  end

  def create
    @feed = Feedzirra::Feed.fetch_and_parse("http://vnexpress.net/rss/gl/trang-chu.rss")
    user = User.find_by_email(params[:session][:email])
    if user
      if user.can_login?
        if user.authenticate(params[:session][:password])
          flash[:success] = "Welcome to Canpass"
          sign_in user
          redirect_to user
        else
          user.update_login_fail
          flash[:error] = "Invalid email/password combination"
          render :new
        end
      else
        flash[:error] = "You are blocked for 5 minutes. Please try again later"
        render :new
      end
    else
      flash[:error] = "Invalid email/password combination"
      render :new
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end
  
  def resend_password
    user = User.find_by_email(params[:email])
    if verify_recaptcha(:message => "Oh! It's error with reCAPTCHA!")
      if user && params[:captcha] == "123456"
        user.password = SecureRandom.urlsafe_base64(6)
        user.save
        @success = "Password send ok"
        UserMailer.send_password(user, user.password).deliver
      else
        @error = "Invalid email/captcha"
      end
      respond_to do |format|
        format.js
      end
    end
  end
end