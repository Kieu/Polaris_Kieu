class ConversionsController < ApplicationController
  before_filter :signed_in_user
  before_filter :must_super_agency
  before_filter :get_promotion, only: [:index, :new, :edit]
  before_filter :get_conversion, only: [:edit, :update]

  def index
    @conversions = params[:promotion_id].blank? ? Array.new :
        Conversion.get_by_promotion_id(params[:promotion_id]).order_by_conversion_name
  end

  def new
    @conversions = params[:promotion_id].blank? ? Array.new :
        Conversion.get_by_promotion_id(params[:promotion_id]).order_by_conversion_name
    @conversion = Conversion.new
  end

  def create
    @conversion = Conversion.new(params[:conversion])
    @conversion.create_user_id = current_user.id
    @conversion.promotion_id = params[:promotion_id]
    if @conversion.save
      @conversion.create_mv
      flash[:error] = "Conversion created"
      redirect_to conversions_path(promotion_id: params[:promotion_id])
    else
      @promotion = Promotion.find(params[:promotion_id])
      render :new
    end
  end

  def edit
    @conversions = params[:promotion_id].blank? ? Array.new :
        Conversion.get_by_promotion_id(params[:promotion_id]).order_by_conversion_name
  end

  def update
    @conversion.update_user_id = current_user.id
    if @conversion.update_attributes(params[:conversion])
      flash[:error] = "Conversion updated"
      redirect_to conversions_path(promotion_id: @conversion.promotion_id)
    else
      render :edit
    end
  end

  private
  def get_promotion
    @promotion = Promotion.find(params[:promotion_id])
  end

  def get_conversion
    @conversion = Conversion.find(params[:id])
  end
end
