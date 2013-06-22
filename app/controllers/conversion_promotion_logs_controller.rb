require "resque"
class ConversionPromotionLogsController < ApplicationController
before_filter :signed_in_user
before_filter :set_cookies

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
      Promotion.active.get_by_client(@client_id).order_by_roman_name
  @array_conversion = Conversion.where(promotion_id: @promotion.id).order(:roman_name).select("id")
                           .select("CASE WHEN LENGTH(conversion_name) > #{Settings.MAX_JA_LENGTH_NAME}
                                   THEN SUBSTRING(conversion_name, 1, #{Settings.MAX_JA_LENGTH_NAME})
                                    ELSE  conversion_name END as conversion_name ")
   @array_account = Account.where(promotion_id: @promotion.id).order(:account_name).select("id")
                           .select("CASE WHEN LENGTH(account_name) > #{Settings.MAX_JA_LENGTH_NAME}
                                   THEN SUBSTRING(account_name, 1, #{Settings.MAX_JA_LENGTH_NAME})
                                    ELSE  account_name END as account_name ")
end

def get_conversion_logs_list
  start_date = params[:start_date].strip
  end_date = params[:end_date].strip
  promotion_id = params[:query]
  @conversion_logs = ConversionLog.get_all_logs(promotion_id, params[:page], params[:rp],params[:cv_id], params[:media_category_id],
                     params[:account_id], start_date, end_date, cookies[:ser],  params[:sortname], params[:sortorder])
  rows = get_rows(@conversion_logs) if @conversion_logs
  count = ConversionLog.get_count(promotion_id,params[:cv_id], params[:media_category_id], params[:account_id],
                                  start_date, end_date, cookies[:ser])
  render json: {page: params[:page], total: count, rows: rows}
end


def download_csv
    background_job = BackgroundJob.create
      promotion = Promotion.find(params[:promotion_id].to_i)
      breadcrumb = "#{promotion.client.client_name} >> #{promotion.promotion_name} >> CV Logs"
      start_date = Date.strptime(params[:start_date].strip, I18n.t("time_format")).strftime("%Y%m%d")
      end_date = Date.strptime(params[:end_date].strip, I18n.t("time_format")).strftime("%Y%m%d") 
      job_id = ExportConversionLogsData.create(user_id: current_user.id,
       promotion_id: params[:promotion_id].to_i,
       conversion_id: params[:conversion_id],
       media_category_id: params[:media_category_id],
       account_id: params[:account_id], start_date: start_date,
       end_date: end_date, show_error: cookies[:ser],
       breadcrumb: breadcrumb,
       bgj_id: background_job.id)
       
    background_job.job_id = job_id
    background_job.save!
    render text: "processing"
end

def get_rows conversion_logs
  accounts = Account.select("id, account_name")
  medias = Media.select("id, media_name")
  campaigns = DisplayCampaign.select("id, name")
  ad_groups = DisplayGroup.select("id, name")
  ads = DisplayAd.select("id, name")
  conversions = Conversion.select("id, conversion_name")
  conversion_categories = [I18n.t("conversion.conversion_category.web"), I18n.t("conversion.conversion_category.app.label"), I18n.t("conversion.conversion_category.combination")]
  os = [I18n.t("conversion.conversion_category.app.os.android"), I18n.t("conversion.conversion_category.app.os.ios")]
  rows = Array.new
  conversion_logs.each do |conversion_log|
    rows << {id: conversion_log.id, cell:{conversion_utime: Time.at(conversion_log.conversion_utime).strftime("%Y/%m/%d %H:%M:%S"),
                                          conversion_id: conversions.find_by_id(conversion_log.conversion_id).conversion_name,
                                          conversion_category: conversion_categories[conversion_log.conversion_category.to_i-1],
                                          tracking_type: I18n.t("log_track_type")[conversion_log.track_type.to_i-1],
                                          cv_type: I18n.t("log_repeat_flg")[conversion_log.repeat_flg.to_i],
                                          approval_status: conversion_log.approval_status,
                                          media_id: medias.find_by_id(conversion_log.media_id).media_name, 
                                          account_id: accounts.find_by_id(conversion_log.account_id).account_name, 
                                          campaign_id: campaigns.find_by_id(conversion_log.campaign_id).name,
                                          group_id: ad_groups.find_by_id(conversion_log.group_id).name, 
                                          unit_id: ads.find_by_id(conversion_log.unit_id).name,
                                          click_utime: Time.at(conversion_log.click_utime).strftime("%Y/%m/%d %H:%M:%S"),
                                          sales: conversion_log.sales,
                                          verify: conversion_log.verify,
                                          suid: conversion_log.suid,
                                          session_id: conversion_log.session_id,
                                          os: os[conversion_log.device_category.to_i-1],
                                          repeat: conversion_log.repeat_processed_flg,
                                          log_state: conversion_log.log_state,
                                          sales: conversion_log.sales,
                                          volume: conversion_log.volume,
                                          others: conversion_log.others,
                                          error_code: I18n.t("log_cv_error_messages")[conversion_log.error_code.to_i],
                                          media_category_id: conversion_log.media_category_id,
                                          profit: conversion_log.profit
                                           }}
  end
  rows
end

def change_medias_list
    if params[:cid].to_i > 0
      render json: Account.where(media_category_id: params[:cid])
    else
      render json: Account.all
    end

end

private
  def set_cookies
    cookies[:cv_options] = Settings.cookie_cv_log_default if !cookies[:cv_options]
    cookies[:ser] = "1" if !cookies[:ser]
  end
end
