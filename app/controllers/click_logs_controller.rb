require "resque"
class ClickLogsController < ApplicationController
  before_filter :signed_in_user
  before_filter :must_super_agency
  before_filter :set_cookie
  def index
    @promotion = Promotion.find(params[:id])
  end

  def get_logs_list
    cookies[:options]= params[:cookie] if params[:cookie]
    rows = get_rows(ClickLog.get_all_logs(params[:query], params[:page], params[:rp], params[:sortname], params[:sortorder], params[:cid], params[:account_id], cookies[:cs], cookies[:ce], cookies[:ser] ))
    render json: {page: params[:page], total: ClickLog.get_log_count(params[:query].to_i, params[:cid], params[:account_id], cookies[:cs], cookies[:ce], cookies[:ser] ), rows: rows}
    
  end  
  
  def download_csv
    Resque.enqueue ExportClickLogsData, current_user.id, params[:promotion_id].to_i, params[:media_category_id], params[:account_id], cookies[:cs], cookies[:ce], cookies[:ser]
    
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
      rows << {id: log.id, cell: {click_utime: log.click_utime, media_id: medias.find_by_id(log.media_id).media_name, media_category_id: log.media_category_id,
              account_id: accounts.find(log.account_id).account_name, campaign_id: display_campaigns.find(log.campaign_id).name, group_id: display_groups.find(log.group_id).name,
              unit_id: display_ads.find(log.unit_id).name, redirect_url: log.redirect_url, session_id: log.session_id,
              device_category: os[log.device_category.to_i], state: log.state, error_code: log.error_code}}
    end
    rows
  end  
  
  def set_cookie
    cookies[:coptions]="11111101010" if !cookies[:coptions]
    time = Time.new
    cookies[:cs]="#{time.year}/#{time.month}/01" if !cookies[:s] 
    cookies[:ce]="#{time.year}/#{time.month}/#{time.day}" if !cookies[:e]   
  end
end
