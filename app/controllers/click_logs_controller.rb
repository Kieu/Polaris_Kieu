require "resque"
class ClickLogsController < ApplicationController
  before_filter :signed_in_user
  before_filter :set_cookie
  def index
    @start_date = params[:start_date].present? ? params[:start_date] :
          Date.yesterday.at_beginning_of_month.strftime(I18n.t("time_format"))
        @end_date = params[:end_date].present? ? params[:end_date] :
          Date.yesterday.strftime(I18n.t("time_format"))
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
                           .select("CASE WHEN LENGTH(account_name) > #{Settings.MAX_JA_LENGTH_NAME}
                                   THEN SUBSTRING(account_name, 1, #{Settings.MAX_JA_LENGTH_NAME})
                                    ELSE  account_name END as account_name ")
  end

  def get_logs_list
    rows = get_rows(ClickLog.get_all_logs(params[:query], params[:page], params[:rp], params[:sortname], params[:sortorder], params[:cid], params[:account_id], params[:start_date].strip, params[:end_date].strip, cookies[:cser] ))
    render json: {page: params[:page], total: ClickLog.get_log_count(params[:query].to_i, params[:cid], params[:account_id], params[:start_date].strip, params[:end_date].strip, cookies[:cser] ), rows: rows}
    
  end  
  
  def download_csv
    
    start_date = Date.strptime(params[:start_date].strip, I18n.t("time_format")).strftime("%Y%m%d")
    end_date = Date.strptime(params[:end_date].strip, I18n.t("time_format")).strftime("%Y%m%d")
    promotion = Promotion.find(params[:promotion_id].to_i)
    breadcrumb = "#{promotion.client.client_name} >> #{promotion.promotion_name} >> CV Logs"
    background_job = BackgroundJob.create
    job_id = ExportClickLogsData.create(user_id: current_user.id,
    promotion_id: params[:promotion_id].to_i,
    media_category_id: params[:media_category_id],
    account_id: params[:account_id], start_date: start_date,
    end_date: end_date, show_error: cookies[:cser],
    breadcrumb: breadcrumb,
    bgj_id: background_job.id)
    background_job.user_id =  current_user.id
    background_job.breadcrumb =  breadcrumb
    background_job.job_id = job_id
    background_job.type_view = Settings.type_view.DOWNLOAD
    background_job.status = Settings.job_status.PROCESSING
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
    os = [ I18n.t("conversion.conversion_category.app.os.ios"), I18n.t("conversion.conversion_category.app.os.android")]
    
    rows = Array.new
      if click_logs && click_logs.count > 0
        click_logs.each do |log|
          rows << {id: log.id, cell: {click_utime: Time.at(log.click_utime.to_i).strftime("%Y/%m/%d %H:%M:%S"), media_id: medias.find(log.media_id).media_name, media_category_id: log.media_category_id,
                  account_id: accounts.find(log.account_id).account_name, campaign_id: display_campaigns.find(log.campaign_id).name, group_id: display_groups.find(log.group_id).name,
                  unit_id: display_ads.find(log.unit_id).name, redirect_url: log.redirect_url, session_id: log.session_id,
                  device_category: os[log.device_category.to_i-1], state: log.state, error_code: I18n.t("log_error_messages")[log.error_code.to_i]}}
        end
      end
    rows
  end  
  
  def set_cookie
    cookies[:coptions]=Settings.cookie_click_log_default if !cookies[:coptions]
    cookies[:cser] = "1" if !cookies[:cser]
  end
end
