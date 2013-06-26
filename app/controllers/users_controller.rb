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
    @prevent = "0"
  end
  
  def create
    @user = User.new(params[:user])
    @prevent = "1"
    @user.password = SecureRandom.urlsafe_base64(6)
    @user.create_user_id = current_user.id
    if @user.valid?
      @user.save!
      if @user.client?
        ClientUser.create(client_id: @user.company_id, user_id: @user.id)
      end
      flash[:success] = I18n.t("user.flash_messages.success")
      if @user.password_flg == "1"
        job_id = SendMail.create(user: @user, password: @user.password)
      end
      redirect_to new_user_path
    else
      render :new
    end
  end
  
  def edit
    @user = User.find(params[:id])
    @prevent = "0"
  end
  
  def update
    @user = User.find(params[:id])
    @prevent = "1"
    @user.update_user_id = current_user.id
    @user.attributes = params[:user]
    if @user.valid?
      if (@user.active? && params[:deactive] == "on") || (!@user.active? && !params[:deactive])
        @user.toggle_enabled
      else
        @user.save!
      end
      flash[:success] = I18n.t("user.flash_messages.update")
      redirect_to users_path
    else
      render :edit
    end
  end
  
  def get_users_list
    rows = get_rows(User.order('role_id').page(params[:page]).per(params[:rp]))
    render json: {page: params[:page], total: User.count, rows: rows}
  end

  def change_company_list
    model = params[:model].constantize
    if model == Client
      render json: model.active.all
    else
      render json: model.all
    end
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
               link: link, roman_name: short_en_name(user.roman_name),
               username: short_ja_name(user.username), company: short_ja_name(company),
               email: short_en_name(user.email), role: user.role.role_name}}
    end
    rows
  end
  
  def must_not_himself
    redirect_to users_path if current_user.id == params[:id].to_i
  end
end
