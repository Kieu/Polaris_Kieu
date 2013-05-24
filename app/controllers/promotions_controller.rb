class PromotionsController < ApplicationController
  before_filter :signed_in_user

  def index
  	if(current_user.role_id == Settings.role.CLIENT)
  		clientId = current_user.company_id
  	elsif
  		clientId = params[:clientId]
  	end

  	@aryPromotion = Promotion.where("client_id = ? ", clientId).order('promotion_name')
  end

  def show
  end
end