class UsersController < ApplicationController
  before_filter :signed_in_user
  before_filter :must_super
  before_filter :must_not_himself, only: [:edit, :update]
  
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
      if @user.client?
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
    @user.update_user_id = current_user.id
    @user.attributes = params[:user]
    if @user.valid?
      @user.save!
      flash[:success] = "Update successfull"
      redirect_to users_path
    else
      render :edit
    end
  end
  
  def enable_disable_user
    user = User.find_by_id(params[:id])
    user.toggle_enabled
    render text: "ok"
  end

  def get_users_list
    rows = get_rows(User.order('role_id').page(params[:page]).per(params[:rp]))
    render json: {page: params[:page], total: User.count, rows: rows}
  end

  def change_company_list
    render json: params[:model].constantize.all
  end

  private
  def get_rows users
    rows = Array.new
    users.each do |user|
      company = ""
      if user.client?
        if client = Client.find_by_id(user.company_id)
          company = client.client_name
        end
      else
        if agency = Agency.find_by_id(user.company_id)
          company = agency.agency_name
        end
      end
      link = user.id == current_user.id ?
         "" : "<a href='users/#{user.id}/edit'>#{view_context.image_tag("/assets/img_edit.png")}</a>"
      rows << {id: user.id, cell: {
               link: link, roman_name: user.roman_name, username: user.username, company: company,
               email: user.email, role: user.role.role_name}}
    end
    rows
  end
  
  def must_not_himself
    redirect_to users_path if current_user.id == params[:id].to_i
  end
end
