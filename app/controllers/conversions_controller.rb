class ConversionsController < ApplicationController
  before_filter :signed_in_user
  before_filter :must_super_agency
  before_filter :get_promotion, only: [:index, :new, :edit]
  before_filter :get_conversion, only: [:edit, :update]
  before_filter :get_list_conversions

  def index
  end

  def new
    @conversion = Conversion.new
    @converions = Conversion.where(promotion_id: params[:promotion_id])
  end

  def create
    @conversion = Conversion.new(params[:conversion])
    @conversion.create_user_id = current_user.id
    @conversion.promotion_id = params[:promotion_id]
    conversion_combine = ''
    if params[:op] && params[:op].count > 0
      params[:op].each_with_index do |op, idx|
           if idx == 0
             if params[:cv][idx].present?
              conversion_combine << "#{params[:cv][idx]}_#{params[:cv_kind][idx]}"
             end
           else
            if params[:cv][idx].present?
              conversion_combine << "|#{op}|#{params[:cv][idx]}_#{params[:cv_kind][idx]}"
             end
           end   
      end
    end
    @conversion.conversion_combine = conversion_combine
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
  
  def get_list_conversions
    @conversions = params[:promotion_id].blank? ? Array.new :
      Conversion.get_by_promotion_id(params[:promotion_id])
      .order_by_conversion_name
  end
end