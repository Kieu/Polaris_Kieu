class UsersController < ApplicationController
  before_filter :signed_in_user
  before_filter :must_super, except: [:show]
  
  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(params[:user])
    @user.password = SecureRandom.urlsafe_base64(6)
    @user.create_usr_id = current_user.id
    if @user.save
      flash[:success] = "User was successfully created"
      UserMailer.send_password(@user, @user.password).deliver if @user.password_flg == 1
      redirect_to @user
    else
      render :new
    end
  end

  def update
    @user = User.find(params[:id])
    @user.update_usr_id = current_user.id
    if @user.update_attributes(params[:user])
      flash[:success] = "User was successfully updated"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_path
  end
  
  def change_lang
    cookies[:locale] = params[:lang]
    redirect_to request.referer
  end
  
  def get_users_list
    @users = User.all
    @rows = Array.new
    @users.each do |user|
      @rows << {"id" => user.id, "cell" => {"username" => user.username, "role_id" => user.role_id}}
    end
    @data = {"page" => 1, "total" => 1, "rows" => @rows} 
    render json: @data.to_json
  end
end