class PromotionsController < ApplicationController
  before_filter :signed_in_user
  before_filter :must_super_agency, except: [:show, :index]
  before_filter :must_delete_able, only: [:show, :edit, :update, :delete_promotion]

  def index
    if current_user.client?
      @client_id = current_user.company_id
    else
      @client_id = params[:client_id]
    end

    @array_promotion = Promotion.get_by_client(@client_id).order_by_promotion_name
    @promotion = Promotion.find(params[:promotion_id])
    cookies[:promotion] = "11111" unless cookies[:promotion].present?
    @promotion.conversions.each do |conversion|
      cookies[("conversion" + conversion.id.to_s).to_sym] = "1111111110" unless cookies[("conversion" + conversion.id.to_s).to_sym].present?
    end
    
    @promotion_id = @array_promotion.first[:id]
    if(params[:promotion_id])
      @promotion_id = params[:promotion_id]
    end
    
    promotion_data = Array.new
    date_arrange = Array.new

    # just for test
    conversion_id = 1;

    promotion_data, date_arrange = DailySummaryAccount.get_promotion_data(@promotion_id, conversion_id, '20130520', '20130525')
    select_left = 'click'
    select_right = 'cost'
    draw_graph(promotion_data, date_arrange, select_left, select_right)
  end

  def show
    render :index
  end

  def new
    @client_id = params[:client_id]
    @promotion = Promotion.new
  end

  def create
    @promotion = Promotion.new(params[:promotion])
    @promotion.create_user_id = current_user.id
    @promotion.client_id = params[:client_id]
    @promotion.agency_id = current_user.company_id
    if @promotion.save
      flash[:error] = "Promotion created"
      redirect_to new_promotion_path(client_id: params[:client_id])
    else
      @client_id = params[:client_id]
      render :new
    end
  end

  def edit
  end

  def update
    @promotion.update_user_id = current_user.id
    if @promotion.update_attributes(params[:promotion])
      flash[:error] = "Promotion updated"
      redirect_to promotions_path(client_id: @promotion.client_id)
    else
      render :edit
    end
  end

  def delete_promotion
    @promotion.delete
    flash[:error] = "Promotion deleted"
    redirect_to promotions_path(client_id: @promotion.client_id)
  end

  def draw_graph(promotion_data, date_arrange, select_left, select_right)
    array_category = Array.new
    date_arrange.each do |date|
      array_category << date.to_date.strftime("%m/%d")
    end

    @chart = LazyHighCharts::HighChart.new('graph') do |f|
      
      f.series(type: 'spline', name: 'Clicks',
             data: promotion_data['click'],
             color: '#008B8B')
      f.series(type: 'spline', name: 'Cost',
             data: promotion_data['cost'],
             color: '#FFA500')
      f.legend(align: "right", verticalAlign: "top", y: 0, x: -50,
             layout: 'vertical', borderWidth: 0)
      f.xAxis(type: 'date', dateTimeLabelFormats: {day: '%e. %b', month: '%e. %b'},
            categories: array_category, labels: {rotation: -45,
              style: {color: '#6D869F', font: '12px Helvetical'}})
      f.yAxis(min: 0, title: '')
    end
    
  end

  private
  def must_delete_able
    @promotion = Promotion.find_by_id(params[:id])
    redirect_to promotions_path if @promotion.nil? || @promotion.deleted?
  end
end
