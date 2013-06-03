class ClickLogsController < ApplicationController
  before_filter :signed_in_user
  before_filter :must_super_agency
  before_filter :set_cookie
  def index
  end

  def get_logs_list
    cookies[:options]= params[:cookie] if params[:cookie]
    rows = get_rows(ClickLog.get_all_logs(params[:id], params[:page], params[:rp], params[:sortname], params[:sortorder], params[:cid], params[:account_id], cookies[:s], cookies[:e], cookies[:ser] ))
    render json: {page: params[:page], total: ClickLog.get_log_count(params[:id].to_i, params[:cid], params[:account_id], cookies[:s], cookies[:e], cookies[:ser] ), rows: rows}
    
  end  
  
  private
  def get_rows click_logs
    medias = Media.select("id, media_name")
    display_groups = DisplayGroup.where(promotion_id: params[:id]).select("id, name")
    display_ads = DisplayAd.where(promotion_id: params[:id]).select("id, name")
    display_campaigns = DisplayCampaign.where(promotion_id: params[:id]).select("id, name")
    accounts = Account.where(promotion_id: params[:id]).select("id,account_name")
    os = {1 => "Adroid", 2 => "iOS", 9 => "Other"}
    rows = Array.new
    
    click_logs.each do |log|
      rows << {id: log.id, cell: {click_utime: log.click_utime, media_id: medias.find_by_id(log.media_id).media_name,
              account_id: accounts.find(log.account_id).account_name, campaign_id: display_campaigns.find(log.campaign_id).name, ad_group_id: display_groups.find(log.ad_group_id).name,
              ad_id: display_ads.find(log.ad_id).name, redirect_url: log.redirect_url, session_id: log.session_id,
              device_category: os[log.device_category.to_i], state: log.state, error_code: log.error_code}}
    end
    rows
  end  
  
  def set_cookie
    cookies[:options]="11111101010" if !cookies[:options]
    time = Time.new
    cookies[:s]="#{time.year}/#{time.month}/01" if !cookies[:s] 
    cookies[:e]="#{time.year}/#{time.month}/#{time.day}" if !cookies[:e]   
  end
end
