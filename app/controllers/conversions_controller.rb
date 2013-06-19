class ConversionsController < ApplicationController
  before_filter :signed_in_user
  before_filter :must_super_agency
  before_filter :get_promotion, only: [:index, :new, :edit, :get_tag]
  before_filter :get_conversion, only: [:edit, :update, :get_tag]
  before_filter :get_list_conversions

  def index
  end

  def new
    @conversion = Conversion.new
    @conversions = Conversion.where(promotion_id: params[:promotion_id])
    @conversion.session_period = Settings.conversion_session_period_default
    @promotion = Promotion.find(params[:promotion_id])
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
    @conversions = Conversion.where(promotion_id: params[:promotion_id])
    @conversion.session_period = Settings.conversion_session_period_default
    if (@conversion.conversion_combine.present?)
      combine = @conversion.conversion_combine.split('|')
      @cv_list = Hash.new
      @cv_kind_list = Hash.new
      @op_list = Hash.new
      conversions = Conversion.where(promotion_id: params[:promotion_id]).select("id, conversion_name")
      combine.each_with_index do |v, idx|
          
          if idx % 2 == 0
            cv = v.split('_')
            @cv_list[idx/2] = {"id" => cv[0], "name" => conversions.find(cv[0].to_i).conversion_name}
            @cv_kind_list[idx/2] = {"id" => cv[1], "name" => I18n.t(Settings.conversion_kind[cv[1].to_i])}
          else
            @op_list[idx/2] = v
          end
      end  
    end
  end

  def update
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
    @conversion.update_user_id = current_user.id
    @conversion.attributes = params[:conversion]
    
    if @conversion.save
      flash[:error] = "Conversion updated"
      redirect_to conversions_path(promotion_id: @conversion.promotion_id)
    else
      @promotion = Promotion.find(params[:promotion_id])
      render :edit
    end
  end

  def get_tag
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
