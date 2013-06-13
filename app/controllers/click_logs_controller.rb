require "resque"
class ClickLogsController < ApplicationController
  before_filter :signed_in_user
  before_filter :must_super_agency
  before_filter :set_cookie
  def index
    @promotion = Promotion.find(params[:promotion_id])
    if current_user.client?
      @client_id = current_user.company_id
    else
      @client_id =@promotion.client_id
    end
    @promotions = @client_id.blank? ? Array.new :
        Promotion.get_by_client(@client_id).order_by_promotion_name
  end

  def get_logs_list
    cookies[:options]= params[:cookie] if params[:cookie]
    rows = get_rows(ClickLog.get_all_logs(params[:query], params[:page], params[:rp], params[:sortname], params[:sortorder], params[:cid], params[:account_id], cookies[:cs], cookies[:ce], cookies[:ser] ))
    render json: {page: params[:page], total: ClickLog.get_log_count(params[:query].to_i, params[:cid], params[:account_id], cookies[:cs], cookies[:ce], cookies[:ser] ), rows: rows}
    
  end  
  
  def download_csv
    background_job = BackgroundJob.create
    job_id = ExportClickLogsData.create(user_id: current_user.id,
      promotion_id: params[:promotion_id].to_i,
      media_category_id: params[:media_category_id],
      account_id: params[:account_id], start_date: cookies[:cs],
      end_date: cookies[:ce], show_error: cookies[:ser],
      bgj_id: background_job.id)
    background_job.job_id = job_id
    background_job.save!
    
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
    cookies[:coptions]="11111101010" if !cookies[:coptions]
    time = Time.new
    cookies[:cs]=Date.yesterday.at_beginning_of_month.strftime("%Y/%m/%d") if !cookies[:cs] 
    cookies[:ce]=Date.yesterday.strftime("%Y/%m/%d") if !cookies[:ce]   
  end
end
