class SessionsController < ApplicationController
  require "feedzirra"
  
  def new
    @feed = Feedzirra::Feed
    fetch_and_parse("http://www.septeni-holdings.co.jp/cp.xml")
    @press_release = PressRelease.all
  end

  def create
    @errors = Array.new
    @feed = Feedzirra::Feed
    fetch_and_parse("http://www.septeni-holdings.co.jp/cp.xml")
    @press_release = PressRelease.all
    user = User.find_by_email(params[:session][:email])
    if user
      if user.can_login?
        if user.authenticate(params[:session][:password])
          flash[:success] = "Welcome to Canpass"
          sign_in user
          cookies[:locale] = params[:language]
          if user.role_id == Settings.role.CLIENT
            redirect_to promotions_path
          else
            redirect_to clients_path
          end
        else
          user.update_login_fail
          @errors << "Invalid email/password combination"
          render :new
        end
      else
        if user.status == Settings.user.deactive 
          @errors << "You are deactive"
        else
          @errors << "You are blocked for 5 minutes. Please try again later"
        end
        render :new
      end
    else
      @errors << "Invalid email/password combination"
      render :new
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end

  def resend_password
    @feed = Feedzirra::Feed
    fetch_and_parse("http://www.septeni-holdings.co.jp/cp.xml")
    @press_release = PressRelease.all
    @form_errors = Array.new
    user = User.find_by_email(params[:email])
    if verify_recaptcha
      if user
        user.password = SecureRandom.urlsafe_base64(6)
        user.save
        UserMailer.send_password(user, user.password).deliver
        flash[:send_success] = "Send password ok"
        redirect_to signin_path
      else
        @form_errors << "Email not found"
        render :new
      end
    else
      @form_errors << flash[:recaptcha_error]
      render :new
    end
  end
end