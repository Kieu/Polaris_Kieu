
require 'csv'

# export conversion data table from conversion log screen to csv file
class ExportConversionLogsData
  @queue = :default

  def self.perform user_id, promotion_id, conversion_id, media_category_id, account_id, start_date, end_date, show_error
    # make file name
    # file name fomat: {user_id}_export_cv_logs_{current_date}.csv
  	file_name = user_id.to_s + "_" + Settings.EXPORT_CV_LOGS + Date.today.to_s + Settings.file_type.CSV

    # initial this task
    background_job = BackgroundJob.new
    background_job.user_id = user_id
    background_job.filename = file_name
    background_job.type_view = Settings.type_view.DOWNLOAD
    background_job.status = Settings.job_status.PROCESSING
    background_job.save!
    
    @promotion_id = promotion_id

    # store csv file on server
    # path: doc/conversion_logs_export
    path_file = Settings.export_conversion_logs_path + file_name
    @array_results = Hash.new

    begin
      header_col = ["CV date time", "CV name", "CV category", "Tracking type", "CV type",
                    "Log ID", "Starting log ID", "Media approval", "Client name", "Promotion", 
                     "Media", "Account", "Campaign", "Ad group", "Ad name",
                     "Link URL", "Click date time", "Influx original", "sales", "volume",
                     "Other", "verify", "SUID", "sesid", "OS",
                     "Repeat", "OK/NG", "User_Agent", "Remote IP", "Referrer",
                     "Media session ID", "mark", "Reception log", "Send log", "Send date time", "Error message"]
      rows = ConversionLog.get_logs(promotion_id, conversion_id, media_category_id, account_id, start_date, end_date, show_error)

      promotion = Promotion.find(promotion_id)
      client_name = promotion.client.client_name
      conversions = Conversion.where(promotion_id: promotion_id)
      medias = Media.select("id, media_name")
      accounts = Account.where(promotion_id: promotion_id).select("id, account_name")
      display_groups = DisplayGroup.where(promotion_id: promotion_id).select("id, name")
      display_ads = DisplayAd.where(promotion_id: promotion_id).select("id, name")
      display_campaigns = DisplayCampaign.where(promotion_id: promotion_id).select("id, name")
      os = {1 => "Android", 2 => "iOS", 9 => "Other"}
      cv_categories = {0 => I18n.t('conversion.conversion_category.web'), 1 => I18n.t('conversion.conversion_category.app'), 2 => I18n.t('conversion.conversion_category.combination')}
      CSV.open(path_file, "wb") do |csv|
        # make header for CSV file
        csv << header_col
        rows.each do |row|
          csv << [row.conversion_utime, conversions.find(row.conversion_id).conversion_name,cv_categories[conversions.find(row.conversion_id).conversion_category], row.conversion_type, row.repeat_flg,
                  row.id, row.parent_conversion_id, row.approval_status, client_name, promotion.promotion_name,
                  medias.find(row.media_id).media_name, accounts.find(row.account_id).account_name, display_campaigns.find(row.campaign_id).name,
                  display_groups.find(row.group_id).name, display_ads.find(row.unit_id), row.redirect_url, row.click_time, row.click_referrer, row.sales,
                  row.volume, row.others, row.verify, row.suid,row.session_id, os[row.device_category], row.repeat_proccessed_flg, row.log_state, row.user_agent,
                  row.remote_ip, row.referrer, row.media_session_id, row.mark, row.request_uri, row.send_url, row.send_utime, row.error_message]
        end
      end
      
      # success case
      background_job.status = Settings.job_status.SUCCESS
      background_job.save!
    rescue
      # false case
      background_job.status = Settings.job_status.FALSE
      background_job.save!   
    ensure
        
    end
    
  end

end