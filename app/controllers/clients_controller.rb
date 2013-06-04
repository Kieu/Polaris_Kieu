class ClientsController < ApplicationController
  before_filter :signed_in_user
  before_filter :must_super_agency, only: [:index, :show]
  before_filter :must_super, only: [:new, :create, :edit, :update, :destroy,
                                    :del_client]
  before_filter :must_deleteable, only: [:show, :edit, :update, :destroy]
  before_filter :load_list_clients, except: [:destroy, :del_client]

  #get all clients sorted by romaji name
  def index
    if @clients.count > 0
      @client = params[:client_id].blank? ? @clients[0] :
        Client.find_by_id(params[:client_id])
      @client = @clients[0] unless @client
    else
      @clients = Array.new
    end
  end

  #get list promotion and paging
  def get_promotions_list
    # get params for paging
    unless params[:id].blank?
      @client_id = params[:id]
    else
      @client_id = @clients[0].id
    end

    rows = Array.new
    rows = get_rows(Promotion.get_by_client(@client_id).order_by_promotion_name.page(params[:page]).per(params[:rp]), @client_id)
    count = Promotion.get_by_client(@client_id).order_by_promotion_name.count

    render json: {page: params[:page], total: count, rows: rows}
  end

  def new
    @client = Client.new
  end

  def create
    @client = Client.new(params[:client])
    @client.create_user_id = current_user.id

    if @client.valid?
      ActiveRecord::Base.transaction do
        @client.save!
        if params[:users_id]
          if !@client.update_client_users(params)
            flash[:error] = "Can not create user for client"
            raise ActiveRecord::Rollback
          end
        end
      end
      if flash[:error]
        render :new
      else
        flash[:error] = "Client was successfully created"
        redirect_to new_client_path
      end
    else
      render :new
    end
  end

  def edit
  end

  def update
    @client.attributes = params[:client]
    @client.update_user_id = current_user.id
    if @client.valid?
      ActiveRecord::Base.transaction do
        @client.save!
        if params[:users_id]
          if !@client.update_client_users(params)
            flash[:error] = "Can not update user for client"
            raise ActiveRecord::Rollback
          end
        end
      end
      if flash[:error]
        render :edit
      else
        flash[:error] = "Edit successfull"
        redirect_to clients_path
      end
    else
      render :edit
    end
  end

  def destroy
    @client.destroy
    redirect_to clients_path
  end

  def del_client
    @client = Client.find_by_id(params[:client_id])
    @client.del_flg = 1
    @client.save
    render text: "ok"
  end

  private
  def must_deleteable
    @client = Client.find(params[:id])
    redirect_to clients_path if @client.nil? || @client.del_flg == 1
  end

  def get_rows(promotions, client_id)
    rows = Array.new
    promotions.each do |promotion|
      promotion_name = view_context.link_to(promotion.promotion_name,
        "javascript:void(0)",
        class: "edit",
        id: "edit#{index}",
        onclick: "ajaxCommon('#{promotions_path(promotion_id: promotion.id,
          client_id: client_id)}', '', '', '','#sidebar,#container')"
      )
      rows << {id: promotion.id, cell: {promotion_name: promotion_name}}
    end
    rows
  end

  def load_list_clients
    if current_user.super?
      @clients = Client.active.order_by_roman_name
    elsif current_user.agency?
      @clients = Array.new
      array_client_user = current_user.client_users.active
      array_client_user.each do |client_user|
        @clients << client_user.client
      end
    end
  end
end
