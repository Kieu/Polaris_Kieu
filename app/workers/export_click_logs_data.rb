require 'csv'

# export click logs data table from click logs screen to csv file
class ExportClickLogsData
  include Resque::Plugins::Status
  @queue = :click_logs

  def perform
    # make file name
    # file name fomat: {user_id}_export_click_logs_{current_date}.csv
  	file_name = options['user_id'].to_s + "_" + Settings.EXPORT_CLICK_LOGS + 
      Date.today.to_s + Settings.file_type.CSV

    # initial this task
    background_job = BackgroundJob.find(options['bgj_id'])
    background_job.user_id = options['user_id']
    background_job.filename = file_name
    background_job.type_view = Settings.type_view.DOWNLOAD
    background_job.status = Settings.job_status.PROCESSING
    background_job.save!
    
    # store csv file on server
    # path: doc/click_logs_export
    path_file = Settings.export_click_logs_path + file_name

    begin
      header_col = ["Click Time", "click ID", "Client name", "Promotion", "Media",
                    "Account name", "Campaign name", "Ad group", "Ad name", "Ad URL",
                     "link URL", "sesid", "Media session ID", "OS", "User_Agent",
                     "Remote IP", "Referer", "mark", "OK/NG", "Error code"]
      rows = ClickLog.get_logs(options['promotion_id'], options['media_category_id'],
        options['account_id'], options['start_date'], options['end_date'],
        options['show_error'])
      promotion = Promotion.find(options['promotion_id'])
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
                  row.remote_ip, row.referrer, row.mark, row.state, row.error_code]
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
