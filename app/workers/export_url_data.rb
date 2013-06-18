require 'csv'

# export promotion data table from promotion screen to csv file
class ExportUrlData
  include Resque::Plugins::Status
  @queue = :export_url

  def perform
    # make file name
    # file name fomat: {user_id}_export_url_{current_date}.csv
    file_name = options['user_id'].to_s + "_" + Settings.EXPORT_URL +
      "_" + Time.now.to_i.to_s + Settings.file_type.CSV
    path_file = Settings.export_url_path + file_name

    # initial this task
    background_job = BackgroundJob.find(options['bgj_id'])
    background_job.user_id = options['user_id']
    background_job.filename = file_name
    background_job.filepath = path_file
    background_job.type_view = Settings.type_view.DOWNLOAD
    background_job.status = Settings.job_status.PROCESSING
    background_job.save!
    
    begin
      url_data = Array.new
      url_data = RedirectUrl.get_url_data(options['promotion_id'], options['account_id'],
        options['media_id'], nil, nil, options['start_date'], options['end_date'], 'download')
      
      CSV.open(path_file, "wb") do |csv|
        csv << ["Export Url data"]
        csv << ["Time range: #{options['start_date']} - #{options['end_date']}"]
        csv << [""]
        csv << [""]
        csv << ["Ad Id", "Campaign name", "Group name", "Ad name", "Creative", "URL", "Last modified"]
        url_data.each do |url|
          array_date_csv = Array.new
          array_date_csv << url['ad_id']
          array_date_csv << url['campaign_name']
          array_date_csv << url['group_name']
          array_date_csv << url['ad_name']
          array_date_csv << url['creative_text']
          array_date_csv << url['url']
          array_date_csv << url['last_modified']
          csv << array_date_csv
        end
      end
      # success case
      background_job.status = Settings.job_status.SUCCESS
      background_job.save!
    rescue
      # false case
      background_job.status = Settings.job_status.WRONG
      background_job.save!   
    ensure
    end
  end
end
