# encoding: utf-8
require 'csv'

# export promotion data table from promotion screen to csv file
class ExportPromotionsData
  include Resque::Plugins::Status
  @queue = :export_promotions

  def perform
    # make file name
    # file name fomat: {job_id}_export_promotion_{current_date}.csv
    # get job_id
    job_id = BackgroundJob.where(id: options['bgj_id']).select('job_id').first['job_id']
    start_date = options['start_date']
    end_date = options['end_date']

    promotion_name = Promotion.where(id: options['promotion_id']).select("promotion_name").first['promotion_name']

  	file_name = options['user_id'].to_s + "_" + promotion_name + 
      "_" + Time.now.strftime("%Y%m%d_%H%M%S") + Settings.file_type.CSV
    path_file = Settings.export_promotion_path + file_name
    file_name = promotion_name + "_" + Time.now.strftime("%Y%m%d_%H%M%S") + Settings.file_type.CSV

    # initial this task
    background_job = BackgroundJob.find(options['bgj_id'])
    background_job.user_id = options['user_id']
    background_job.filename = file_name
    background_job.filepath = path_file
    background_job.type_view = Settings.type_view.DOWNLOAD
    background_job.status = Settings.job_status.PROCESSING
    background_job.save!

    # store csv file on server
    # path: doc/promotion_export
    array_results = Hash.new

    begin
      
      # get row data
      index_to_get_data_row = 0
      array_data_row = DailySummaryAccount.get_table_data(options['promotion_id'], start_date, end_date)
      account_col = ["Media", "Account name", "Imp", "Click", "CTR", "COST",
                     "CPM", "CPC"]

      array_conversion = Conversion.where(promotion_id: options['promotion_id'])
      
      # initial count num
      cnt = 1

      # create csv header file
      array_conversion.each do |conversion_element|
        account_col << "CV#{cnt}"
        account_col << "CV#{cnt}(first)"
        account_col << "CV#{cnt}(repeat)"
        account_col << "CVR#{cnt}"
        account_col << "CPA#{cnt}"
        account_col << "ASSIST#{cnt}"
        account_col << "SALES#{cnt}"
        account_col << "ROAS#{cnt}"
        account_col << "PROFIT#{cnt}"
        account_col << "ROI#{cnt}"

        cnt += 1
      end

      cnt = cnt - 1
      CSV.open(path_file, "wb") do |csv|

        # make header for CSV file
        csv << account_col

        # start write content of promotion to file
        media_list = Media.where(" del_flg = 0")
        account_num = 1
        media_list.each do |media|
          account_list = Account.where(" promotion_id = #{options['promotion_id']}
                                      and media_id = #{media.id}")
                                .select(" id, account_name, media_id")

          account_list.each do |account|
            array_medium = Array.new
            current_data_promotion = array_data_row[index_to_get_data_row]["account#{account.id}_promotion"]
            array_medium << media.media_name
            array_medium << account.account_name
            if current_data_promotion != nil
              array_medium << current_data_promotion['imp_count'].to_s
              array_medium << current_data_promotion['click_count'].to_s
              click_through_ratio = current_data_promotion['click_through_ratio'].to_s + "%"
              array_medium << click_through_ratio
              cost_sum = '¥' + (current_data_promotion['cost_sum'].to_s)
              array_medium << cost_sum
              array_medium << current_data_promotion['cost_per_mille'].to_s
              cost_per_click = '¥' + (current_data_promotion['cost_per_click'].to_s)
              array_medium << cost_per_click
            else
              array_medium << nil
              array_medium << nil
              array_medium << nil
              array_medium << nil
              array_medium << nil
              array_medium << nil
            end
            
            (1..cnt).each do |current_index|
              current_data_conversion = array_data_row[index_to_get_data_row]["account#{account.id}_conversion#{current_index}"]
              if current_data_conversion != nil
                array_medium << current_data_conversion['total_cv_count'].to_s
                array_medium << current_data_conversion['first_cv_count'].to_s
                array_medium << current_data_conversion['repeat_cv_count'].to_s
                conversion_rate = current_data_conversion['conversion_rate'].to_s + "%"
                array_medium << conversion_rate
                click_per_action = '¥' + (current_data_conversion['click_per_action'].to_s)
                array_medium << click_per_action
                array_medium << current_data_conversion['assist_count'].to_s
                sales = '¥' + (current_data_conversion['sales'].to_s)
                array_medium << sales
                roas = current_data_conversion['roas'].to_s + "%"
                array_medium << roas
                profit = '¥' + (current_data_conversion['profit'].to_s)
                array_medium << profit
                roi = (current_data_conversion['roi'].to_s) + "%"
                array_medium << roi
              else
                array_medium << nil
                array_medium << nil
                array_medium << nil
                array_medium << nil
                array_medium << nil
                array_medium << nil
                array_medium << nil
                array_medium << nil
                array_medium << nil
                array_medium << nil
              end
            end
            
            csv << array_medium
          end

        end
      end
      # success case
      background_job.status = Settings.job_status.SUCCESS
      background_job.save!
    rescue
      # false case
      background_job.status = Settings.job_status.WRONG
      background_job.save!
    end
  end
end
