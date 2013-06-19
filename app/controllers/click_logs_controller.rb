require "resque"
class ClickLogsController < ApplicationController
  before_filter :signed_in_user
  before_filter :set_cookie
  def index
    @start_date = params[:start_date].present? ? params[:start_date] :
        Date.yesterday.at_beginning_of_month.strftime("%Y/%m/%d")
    @end_date = params[:end_date].present? ? params[:end_date] :
        Date.yesterday.strftime("%Y/%m/%d")
    
    @promotion_id = params[:promotion_id]
    @promotion = Promotion.find(@promotion_id)
    if current_user.client?
      @client_id = current_user.company_id
    else
      @client_id =@promotion.client_id
    end
    @promotions = @client_id.blank? ? Array.new :
        Promotion.active.get_by_client(@client_id).order_by_promotion_name

    @array_account = Account.where(promotion_id: params[:promotion_id]).order(:account_name).select("id")
                           .select("CASE WHEN LENGTH(account_name) > #{Settings.MAX_LENGTH_NAME}
                                   THEN SUBSTRING(account_name, 1, #{Settings.MAX_LENGTH_NAME})
                                    ELSE  account_name END as account_name ")
  end

  def get_logs_list
    cookies[:options]= params[:cookie] if params[:cookie]
    rows = get_rows(ClickLog.get_all_logs(params[:query], params[:page], params[:rp], params[:sortname], params[:sortorder], params[:cid], params[:account_id], params[:start_date], params[:end_date], cookies[:cser] ))
    render json: {page: params[:page], total: ClickLog.get_log_count(params[:query].to_i, params[:cid], params[:account_id], params[:start_date], params[:end_date], cookies[:cser] ), rows: rows}
    
  end  
  
  def download_csv
    background_job = BackgroundJob.create
    job_id = ExportClickLogsData.create(user_id: current_user.id,
    promotion_id: params[:promotion_id].to_i,
    media_category_id: params[:media_category_id],
    account_id: params[:account_id], start_date: params[:start_date],
    end_date: params[:end_date], show_error: cookies[:cser],
    bgj_id: background_job.id)
    
    render text: "processing"
  end
  private
  def get_rows click_logs
    medias = Media.select("id, media_name")
    display_groups = DisplayGroup.where(promotion_id: params[:query]).select("id, name")
    display_ads = DisplayAd.where(promotion_id: params[:query]).select("id, name")
    display_campaigns = DisplayCampaign.where(promotion_id: params[:query]).select("id, name")
    accounts = Account.where(promotion_id: params[:query]).select("id,account_name")
    os = {1 => "Android", 2 => "iOS", 9 => "Other"}
    rows = Array.new
    click_logs.each do |log|
      rows << {id: log.id, cell: {click_utime: log.click_utime, media_id: medias.find(log.media_id).media_name, media_category_id: log.media_category_id,
              account_id: accounts.find(log.account_id).account_name, campaign_id: display_campaigns.find(log.campaign_id).name, group_id: display_groups.find(log.group_id).name,
              unit_id: display_ads.find(log.unit_id).name, redirect_url: log.redirect_url, session_id: log.session_id,
              device_category: os[log.device_category.to_i], state: log.state, error_code: I18n.t("log_error_messages")[log.error_code.to_i]}}
    end
    rows
  end  
  
  def set_cookie
    cookies[:coptions]=Settings.cookie_click_log_default if !cookies[:coptions]
    cookies[:cser] = "1" if !cookies[:cser]
  end
end
