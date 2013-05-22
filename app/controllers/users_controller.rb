class UsersController < ApplicationController
  before_filter :signed_in_user
  before_filter :must_super
  
  def index
  end

  def show
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    @user.password = SecureRandom.urlsafe_base64(6)
    @user.create_user_id = current_user.id
    if @user.valid?
      @user.save!
      if @user.role_id == 2
        ClientUser.create(client_id: @user.company_id, user_id: @user.id)
      end
      flash[:success] = "User was successfully created"
      if @user.password_flg == 0
        UserMailer.send_password(@user, @user.password).deliver
      end
      redirect_to new_user_path
    else
      render :new
    end
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:success] = "Update successfull"
      redirect_to users_path
    else
      render :edit
    end
  end
  
  def enable_disable_user
    user = User.find_by_id(params[:id])
    user.status = user.status == 0 ? "1" : "0"
    user.save
    render text: "ok"
  end

  def get_users_list
    rows = get_rows(User.order_by_roman_name.page(params[:page]).per(params[:rp]))
    render json: {page: params[:page], total: User.where(status: 0).count, rows: rows}
  end

  def search
    if params[:q].blank?
      render :text => ""
      return
    end
    params[:q].gsub!(/'/,'')
    @search = User.search do
      fulltext params[:q]
    end
    lines = @search.results.collect do |item|
      "#{escape_javascript(item['username'])}#!##{item['id']}#!" +
        "##{item['email']}#!##{item.role.role_name}#!#" +
        "#{escape_javascript(item['username'])}"
    end
    if @search.results.count > 0
      render :text => lines.join("\n")
    else
      render text: "test#!#0#!#test#!#test#!#test"
    end
  end
  
  def change_company_list
    render json: params[:model].constantize.all
  end

  private
  def get_rows users
    rows = Array.new
    users.each do |user|
      link = "<a href='users/#{user.id}/edit'>Edit</a>"
      rows << {"id" => user.id, "cell" => {"link" => link,"roman_name" => user.roman_name, 
                "username" => user.username, "company" => user.company,
                "email" => user.email, "role_id" => user.role.role_name}}
    end
    rows
  end
end