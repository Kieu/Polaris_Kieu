class ConversionPromotionLogsController < ApplicationController
before_filter :signed_in_user
before_filter :set_cookies

def index
  @promotion = Promotion.find(params[:promotion_id])
end

def get_conversion_logs_list
  start_date = cookies[:s]
  end_date = cookies[:e]
  promotion_id = params[:id]
  @conversion_logs = ConversionLog.get_all_logs(promotion_id, params[:page], params[:rp],params[:cv_id], params[:media_category_id],
                     params[:account_id], start_date, end_date, cookies[:ser],  params[:sortname], params[:sortorder])
  rows = get_rows(@conversion_logs) if @conversion_logs
  count = ConversionLog.get_count(promotion_id,params[:cv_id], params[:media_category_id], params[:account_id],
                                  start_date, end_date, cookies[:ser])
  render json: {page: params[:page], total: count, rows: rows}
end

def get_rows conversion_logs
  accounts = Account.select("id, account_name")
  medias = Media.select("id, media_name")
  campaigns = DisplayCampaign.select("id, name")
  ad_groups = DisplayGroup.select("id, name")
  ads = DisplayAd.select("id, name")
  conversions = Conversion.select("id, conversion_name")
  rows = Array.new
  conversion_logs.each do |conversion_log|
    rows << {id: conversion_log.id, cell:{conversion_utime: conversion_log.conversion_utime,
                                          conversion_id: conversions.find_by_id(conversion_log.conversion_id).conversion_name,
                                          conversion_category: conversion_log.conversion_category,
                                          tracking_type: conversion_log.conversion_type,
                                          cv_type: conversion_log.repeat_flg,
                                          approval_status: conversion_log.approval_status,
                                          media_id: medias.find_by_id(conversion_log.media_id).media_name, 
                                          account_id: accounts.find_by_id(conversion_log.account_id).account_name, 
                                          campaign_id: campaigns.find_by_id(conversion_log.campaign_id).name,
                                          ad_group_id: ad_groups.find_by_id(conversion_log.group_id).name, 
                                          ad_id: ads.find_by_id(conversion_log.unit_id).name,
                                          click_time: conversion_log.click_time,
                                          sales: conversion_log.sales,
                                          verify: conversion_log.verify,
                                          suid: conversion_log.suid,
                                          session_id: conversion_log.session_id,
                                          os: conversion_log.device_category,
                                          repeat: conversion_log.repeat_proccessed_flg,
                                          log_state: conversion_log.log_state,
                                          sales: conversion_log.sales,
                                          volume: conversion_log.volume,
                                          others: conversion_log.others,
                                          error_message: conversion_log.error_message,
                                          error_log_view: conversion_log.error_log_view,
                                          media_category_id: conversion_log.media_category_id
                                           }}
  end
  rows
end

private
  def set_cookies
    cookies[:options] = "111111111111111000000000" if !cookies[:options]
    time = Time.new
    cookies[:s]="#{time.year}/#{time.month}/01" if !cookies[:s] 
    cookies[:e]="#{time.year}/#{time.month}/#{time.day}" if !cookies[:e]
    cookies[:ser] = "1" if !cookies[:ser]
  end
end
