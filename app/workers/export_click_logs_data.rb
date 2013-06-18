require 'csv'

# export click logs data table from click logs screen to csv file
class ExportClickLogsData
  include Resque::Plugins::Status
  @queue = :click_logs

  def perform
    # make file name
    # file name fomat: {user_id}_export_click_logs_{current_date}.csv   Settings.EXPORT_CLICK_LOGS
    promotion = Promotion.find(options['promotion_id'])
    file_name = options['user_id'].to_s + "_" + promotion.promotion_name + "_click_" +
    Time.now.strftime("%Y%m%d") + Settings.file_type.CSV
    path_file = Settings.export_click_logs_path + file_name
    if File.exist?(path_file)
      return
    end
    # initial this task
     background_job = BackgroundJob.find(options['bgj_id'])
     background_job.user_id = options['user_id']
     background_job.filename = file_name
     background_job.filepath = path_file
     background_job.type_view = Settings.type_view.DOWNLOAD
     background_job.status = '0'
     background_job.save!
    
    # store csv file on server
    # path: doc/click_logs_export

    begin
      header_col = ["Click Time", "click ID", "Client name", "Promotion", "Media",
                    "Account name", "Campaign name", "Ad group", "Ad name", "Ad URL",
                     "link URL", "sesid", "Media session ID", "OS", "User_Agent",
                     "Remote IP", "Referer", "mark", "OK/NG", "Error code"]
      rows = ClickLog.get_logs(options['promotion_id'], options['media_category_id'],
        options['account_id'], options['start_date'], options['end_date'],
        options['show_error'])

      client_name = promotion.client.client_name
      medias = Media.select("id, media_name")
      accounts = Account.where(promotion_id: options['promotion_id']).
        select("id, account_name")
      display_groups = DisplayGroup.where(promotion_id: options['promotion_id']).
        select("id, name")
      display_ads = DisplayAd.where(promotion_id: options['promotion_id']).
        select("id, name")
      display_campaigns = DisplayCampaign.where(promotion_id: options['promotion_id']).
        select("id, name")
      
      CSV.open(path_file, "wb") do |csv|
        # make header for CSV file
        csv << header_col
        rows.each do |row|
          csv << [row.click_utime, row.id, client_name, promotion.promotion_name,
                  medias.find(row.media_id).media_name, accounts.find(row.account_id).account_name,
                  display_campaigns.find(row.campaign_id).name, display_groups.find(row.group_id).name,
                  display_ads.find(row.unit_id).name, row.click_url, row.redirect_url,
                  row.session_id, row.media_session_id, row.device_category, row.user_agent,
                  row.remote_ip, row.referrer, row.mark, row.state, I18n.t("log_error_messages")[row.error_code.to_i]]
        end
      end

      # success case
       background_job.status = '1'
       background_job.save!
    rescue
      # false case
       background_job.status = '2'
       background_job.save!   
    ensure  
    end
  end
end
