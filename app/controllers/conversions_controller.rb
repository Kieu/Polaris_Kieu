class ConversionsController < ApplicationController
  before_filter :signed_in_user
  before_filter :must_super_agency
  before_filter :get_promotion, only: [:index, :new, :edit]

  def index
  end

  def new
    @conversion = Conversion.new
  end

  def create
    @conversion = Conversion.new params[:conversion]
    @conversion.create_user_id = current_user.id
    @conversion.promotion_id = params[:promotion_id]
    if @conversion.save
      flash[:error] = "Conversion created"
      redirect_to conversions_path(promotion_id: params[:promotion_id])
    else
      @promotion = Promotion.find params[:promotion_id]
      render :new
    end
  end

  private
  def get_promotion
    @promotion = Promotion.find params[:promotion_id]
  end
end
