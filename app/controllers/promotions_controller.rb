class PromotionsController < ApplicationController
  before_filter :signed_in_user
  before_filter :must_super_agency, except: [:show, :index]
  before_filter :must_delete_able, only: [:show, :edit, :update, :delete_promotion]

  def index
  	if current_user.client?
  		client_id = current_user.company_id
    else
  		client_id = params[:client_id]
  	end

  	@array_promotion = Promotion.get_by_client(client_id).order_by_promotion_name
    @array_media_category = @array_media = @array_account = @array_conversion = Array.new
    @array_media_category, @array_media, @array_account, @array_conversion = get_master_data

    

    array_category = ['05/02', '05/03', '05/04', '05/05',
          '05/06', '05/07', '05/08', '05/09', 
          '05/10', '05/11', '05/12', '05/13']

    @chart = LazyHighCharts::HighChart.new('graph') do |f|
    f.series(type: 'spline', name: 'Clicks',
             data: [300, 200, 300, 0, 500, 350, 250, 270, 280, 260, 262, 265],
             color: '#008B8B')
    f.series(type: 'spline', name: 'Imp',
             data: [200, 0, 200, 500, 400, 450, 420, 350, 240, 230, 211, 245],
             color: '#FFA500')
    f.legend(align: "right", verticalAlign: "top", y: 0, x: -50,
             layout: 'vertical', borderWidth: 0)
    f.xAxis(type: 'date', dateTimeLabelFormats: {day: '%e. %b', month: '%e. %b'},
            categories: array_category, labels: {rotation: -45,
              style: {color: '#6D869F', font: '12px Helvetical'}})
    f.yAxis(min: 0, title: '')
    end
    
    promotion_data = Array.new
    promotion_data = DailySummaryAccount.get_promotion_data(params[:promotion_id], '20130525', '20130525')
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

  def get_promotions_report
    # get params for paging
    promotion_data = Array.new
    promotion_data = DailySummaryAccount.get_promotion_data(params[:id])
  
    render json: {page: params[:page], total: count, rows: rows}
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

  def destroy
  end

  def delete_promotion
    @promotion.delete
    flash[:error] = "Promotion deleted"
    redirect_to promotions_path(client_id: @promotion.client_id)
  end

  def get_master_data
    # get list conversion 
    array_conversion = Conversion.where(' del_flg = 0 ').select(' id, conversion_name')

    # get list media_category
    array_media_category = Settings.media_category
    
    # get list media
    array_media = Media.where(' del_flg = 0 ').select(' id, media_name, media_category_id')

    # get list account
    array_account = Account.where(' del_flg = 0 ').select(' id, account_name')
    
    return array_media_category, array_media, array_account, array_conversion
  end

  private
  def must_delete_able
    @promotion = Promotion.find_by_id(params[:id])
    redirect_to promotions_path if @promotion.nil? || @promotion.deleted?
  end
end
