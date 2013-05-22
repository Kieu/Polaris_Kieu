class ClientsController < ApplicationController
  before_filter :signed_in_user
  before_filter :must_super_agency, except: [:show]
  before_filter :must_deleteable, only: [:show, :edit, :update, :destroy]
  
  #get all clients sorted by romaji name
  def index
    if(current_user.role_id == Settings.role.SUPER)
	    @clients = Client.find(:all, :order => 'roman_name', :conditions => ['del_flg = 0'])
	  elsif(current_user.role_id == Settings.role.AGENCY)
	    @clients = Array.new
	    aryClientUser = current_user.client_users.where(' del_flg = 0 ')
	    aryClientUser.each do |client_user|
		    @clients << client_user.client
		  end
	  end

    # get client name of 1st client
    @clientName = @clients[0].client_name
  end
  
  #get list promotion and paging
  def get_promotions_list
    #get list clients
    if(current_user.role_id == Settings.role.SUPER)
	    @clients = Client.find(:all, :order => 'roman_name', :conditions => ['del_flg = 0'])
	  elsif(current_user.role_id == Settings.role.AGENCY)
	    @clients = Array.new
	    aryClientUser = current_user.client_users.where(' del_flg = 0 ')
	    aryClientUser.each do |client_user|
		    @clients << client_user.client
		  end
	  end
    
	  # get params for paging
    if(params[:id] != '')
      clientId = params[:id]
    else
      clientId = @clients[0].id
    end

    rows = Array.new
    rows = get_rows(Promotion.where("client_id = ? ", clientId).order_by_promotion_name.page(params[:page]).per(params[:rp]))
    count = Promotion.where("client_id = ? ", clientId).order('promotion_name').count
	
    render json: {page: params[:page], total: count, rows: rows}
  end
  
  def show
    # get client list
    if(current_user.role_id == Settings.role.SUPER)
      @clients = Client.find(:all, :order => 'roman_name', :conditions => ['del_flg = 0'])
    elsif(current_user.role_id == Settings.role.AGENCY)
      @clients = Array.new
      aryClientUser = current_user.client_users.where(' del_flg = 0 ')
      aryClientUser.each do |client_user|
        @clients << client_user.client
      end
    end

    # get current client name
    @clients.each do |client|
      if(client.id == params[:id].to_i)
        @clientName = client.client_name
      end
    end

    @clientId = params[:id]
    render :index

  end

  def new
    @client = Client.new
    if(current_user.role_id == Settings.role.SUPER)
      @clients = Client.find(:all, :order => 'roman_name', :conditions => ['del_flg = 0'])
    elsif(current_user.role_id == Settings.role.AGENCY)
      @clients = Array.new
      aryClientUser = current_user.client_users.where(' del_flg = 0 ')
      aryClientUser.each do |client_user|
        @clients << client_user.client
      end
    end
  end

  def create
    if(current_user.role_id == Settings.role.SUPER)
      @clients = Client.find(:all, :order => 'roman_name', :conditions => ['del_flg = 0'])
    elsif(current_user.role_id == Settings.role.AGENCY)
      @clients = Array.new
      aryClientUser = current_user.client_users.where(' del_flg = 0 ')
      aryClientUser.each do |client_user|
        @clients << client_user.client
      end
    end
    @client = Client.new(params[:client])
    @client.create_user_id = current_user.id
    if @client.save
			if params[:users_id]
		    params[:users_id].each do |user_id|
		      unless params["del_user_" + user_id] == "on"
		        @client.client_users.create(user_id: user_id)
		      end
		    end
			end
      flash[:error] = "Client was successfully created"
      redirect_to new_client_path
    else
      render :new
    end
  end

  def edit
    @client = Client.find(params[:id])
    if(current_user.role_id == Settings.role.SUPER)
      @clients = Client.find(:all, :order => 'roman_name', :conditions => ['del_flg = 0'])
    elsif(current_user.role_id == Settings.role.AGENCY)
      @clients = Array.new
      aryClientUser = current_user.client_users.where(' del_flg = 0 ')
      aryClientUser.each do |client_user|
        @clients << client_user.client
      end
    end
  end

  def update
    @client = Client.find(params[:id])
    @client.attributes = params[:client]
    @client.update_user_id = current_user.id
    if(current_user.role_id == Settings.role.SUPER)
      @clients = Client.find(:all, :order => 'roman_name', :conditions => ['del_flg = 0'])
    elsif(current_user.role_id == Settings.role.AGENCY)
      @clients = Array.new
      aryClientUser = current_user.client_users.where(' del_flg = 0 ')
      aryClientUser.each do |client_user|
        @clients << client_user.client
      end
    end
    if @client.valid?
      @client.save!
			if params[:users_id]
		    params[:users_id].each do |user_id|
		      if params["del_user_" + user_id] == "on"
		        if client_user = @client.client_users.find_by_user_id(user_id)
		          client_user.update_attributes(del_flg: 1)
		        end
		      else
		        if client_user = @client.client_users.find_by_user_id(user_id)
		          client_user.update_attributes(del_flg: 0)
		        else
		          @client.client_users.create(user_id: user_id)
		        end
		      end
		    end
			end
      flash[:error] = "Edit successfull"
      redirect_to clients_path
    else
      render "edit"
    end
  end

  def destroy
    @client = Client.find(params[:id])
    @client.destroy
    redirect_to clients_path
  end

  def del_client
    @client = Client.find_by_id(params[:client_id])
    @client.del_flg = 1
    @client.save
    render text: "ok"
  end
  
  def search
    if params[:q].blank?
      render :text => ""
      return
    end
    params[:q].gsub!(/'/,'')
    @search = Client.search do
      fulltext params[:q]
    end
    lines = @search.results.collect do |item|
      puts item
      "#{escape_javascript(item['client_name'])}#!##{item['id']}#!" +
      "##{item['client_name']}#!##{item['client_name']}#!" +
      "##{escape_javascript(item['client_name'])}"
    end
    if @search.results.count > 0
      render :text => lines.join("\n")
    else
      render text: "test#!#0#!#test#!#test#!#test"
    end
  end

  private
  def must_deleteable
    client = Client.find_by_id(params[:id])
    redirect_to clients_path if client.nil? || client.del_flg == 1
  end

  def get_rows promotions
    rows = Array.new
    romotions.each do |promotion|
      promotionName = "<a href='promotions/id'>#{promotion.promotion_name}</a>"
      rows << {'id' => promotion.id, 'cell' => {'promotion_name' => promotionName}}
    end
    rows
  end
end
