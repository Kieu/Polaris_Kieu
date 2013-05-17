class ClientsController < ApplicationController
  before_filter :signed_in_user
  before_filter :must_super, except: [:show]
  def index
    @clients = Client.where(del_flg: 0)
	@promotions = Array.new
	@clients.each do |client|
	  @promotions = client.promotions
	end
  end
end
