require "resque"
class PromotionsController < ApplicationController
  before_filter :signed_in_user
  before_filter :must_super_agency, except: [:show, :index]
  before_filter :must_delete_able, only: [:show, :edit, :update, :delete_promotion]


  def index
    if current_user.client?
      @client_id = current_user.company_id  
    else
      @promotion = Promotion.find(params[:promotion_id])
      @client_id = @promotion.client_id
    end

    @array_promotion = @client_id.blank? ? Array.new :
      Promotion.get_by_client(@client_id).active.order_by_promotion_name
    if @array_promotion.count > 0
      @promotion_id = params[:promotion_id].blank? ? @array_promotion.first[:id] :
        params[:promotion_id]
    
      @promotion = @array_promotion.find_by_id(@promotion_id)
      if @promotion
        @start_date = params[:start_date].present? ? params[:start_date] :
          Date.yesterday.at_beginning_of_month.strftime("%Y/%m/%d")
        @end_date = params[:end_date].present? ? params[:end_date] :
          Date.yesterday.strftime("%Y/%m/%d")
        cookies[:promotion] = "111111" unless cookies[:promotion].present?
        @promotion.conversions.each do |conversion|
          cookies[("conversion" + conversion.id.to_s).to_sym] = "1111111111" unless
            cookies[("conversion" + conversion.id.to_s).to_sym].present?
        end
        @client_name = Client.find(@client_id).client_name
        @promotion_name = Promotion.find(@promotion_id).promotion_name
        
        @conversions = @promotion.conversions
        
        @media_list = Media.get_media_list
        @account_list = Account.get_account_list(@promotion_id, @media_list)
        
        @promotion_results = DailySummaryAccount
          .get_promotion_summary(@promotion_id, @start_date, @end_date)
        @conversions_results = DailySummaryAccConversion
          .get_conversions_summary(@promotion_id, @start_date, @end_date)
        @promotion_data = Array.new
        date_arrange = Array.new
  
        @promotion_data, date_arrange =
          DailySummaryAccount.get_promotion_data(@promotion_id, @start_date,
            @end_date)
        @array_category = Array.new
        date_arrange.each do |date|
          @array_category << date.to_date.strftime("%m/%d")
        end
        @select_left = params[:left].present? ? params[:left] : "COST"
        @select_right = params[:right].present? ? params[:right] : "click"
      else
        render 'public/404'
      end
    end
  end

  def show
    render :index
  end

  def new
    if current_user.client?
      @client_id = current_user.company_id
    else
      @client_id = params[:client_id] if params[:client_id]
    end
    @promotions = @client_id.blank? ? Array.new :
        Promotion.get_by_client(@client_id).order_by_promotion_name
    @client = Client.find(params[:client_id])
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
      @client = Client.find(params[:client_id])
      render :new
    end
  end

  def edit
    if current_user.client?
      @client_id = current_user.company_id
    else
      @client_id =@promotion.client_id
    end
    @promotions = @client_id.blank? ? Array.new :
        Promotion.get_by_client(@client_id).order_by_promotion_name
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
  
  def change_data
    results = Hash.new
    client_id = params[:client_id]
    promotion_id = params[:promotion_id]
    start_date = params[:start_date]
    end_date = params[:end_date]
    results[:promotion_data], date_arrange =
      DailySummaryAccount.get_promotion_data(promotion_id, start_date,
        end_date)
    results[:array_category] = Array.new
    date_arrange.each do |date|
      results[:array_category] << date.to_date.strftime("%m/%d")
    end
    respond_to do |format|
      format.json{render json: results}
    end
  end

  def download_csv
    promotion_id = params[:promotion_id].to_i
    user_id = current_user.id
    Resque.enqueue ExportPromotionData, user_id, promotion_id
    
    render text: "processing"
  end
  
  def promotion_table
    @promotion_id = params[:promotion_id]
    @client_id = params[:client_id]
    @promotion = Promotion.find(@promotion_id)
    start_date = params[:start_date].present? ? params[:start_date] :
      Date.today.at_beginning_of_month.strftime("%Y/%m/%d").to_s
    end_date = params[:end_date].present? ? params[:end_date] :
      Date.today.strftime("%Y/%m/%d").to_s
    @client_name = Client.find(@client_id).client_name
    @promotion_name = @promotion.promotion_name
    @conversions = @promotion.conversions
        
    @media_list = Media.get_media_list
    @account_list = Account.get_account_list(@promotion_id, @media_list)
        
    @promotion_results = DailySummaryAccount
      .get_promotion_summary(@promotion_id, start_date, end_date)
    @conversions_results = DailySummaryAccConversion
      .get_conversions_summary(@promotion_id,start_date, end_date)
    render layout: false
  end

  private
  def must_delete_able
    @promotion = Promotion.find_by_id(params[:id])
    redirect_to promotions_path if @promotion.nil? || @promotion.deleted?
  end
end
