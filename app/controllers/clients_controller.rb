class ClientsController < ApplicationController
  before_filter :signed_in_user
  before_filter :must_super_agency, except: [:show]
  
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
    
	#get params for paging
	# row per page
	rp = (params[:rp]).to_i
	if(!rp)
      rp = 10
    end
	
	#current page
	page = (params[:page]).to_i
	if (!page)
      page = 1
    end
	start = ((page-1) * rp).to_i
	
	@promotions = Array.new
	#get promotion for each client
	@clients.each do |client|
	  aryPromotion = Promotion.where("client_id = #{client.id} ").order('promotion_name').limit(rp).offset(start)
	  aryPromotion.each do |promotion|
	    @promotions << {'id' => promotion.id, 'cell' => {'promotion_name' => promotion.promotion_name}}
	  end
	end
	
	@data = {"page" => 1, "total" => 1, "rows" => @promotions}
    render json: @data.to_json
  end
  
  def show
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
  end
end


