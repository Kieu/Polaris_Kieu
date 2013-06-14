require "resque"
class ConversionPromotionLogsController < ApplicationController
before_filter :signed_in_user
before_filter :set_cookies

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

def get_conversion_logs_list
  start_date = cookies[:s]
  end_date = cookies[:e]
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
    job_id = ExportConversionLogsData.create(user_id: current_user.id,
      promotion_id: params[:promotion_id].to_i,
      conversion_id: params[:conversion_id],
      media_category_id: params[:media_category_id],
      account_id: params[:account_id], start_date: cookies[:s],
      end_date: cookies[:e], show_error: cookies[:ser],
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
    rows << {id: conversion_log.id, cell:{conversion_utime: conversion_log.conversion_utime,
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
                                          click_time: conversion_log.click_time,
                                          sales: conversion_log.sales,
                                          verify: conversion_log.verify,
                                          suid: conversion_log.suid,
                                          session_id: conversion_log.session_id,
                                          os: os[conversion_log.device_category.to_i-1],
                                          repeat: conversion_log.repeat_proccessed_flg,
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

private
  def set_cookies
    cookies[:cv_options] = "111111111111111000100000" if !cookies[:cv_options]
    time = Time.new
    cookies[:s]=Date.yesterday.at_beginning_of_month.strftime("%Y/%m/%d") if !cookies[:s] 
    cookies[:e]=Date.yesterday.strftime("%Y/%m/%d") if !cookies[:e]
    cookies[:ser] = "1" if !cookies[:ser]
  end
end
