require 'csv'

# export promotion data table from promotion screen to csv file
class ExportPromotionData
  @queue = :export_promotion

  def self.perform user_id, promotion_id

    # make file name
    # file name fomat: {user_id}_export_promotion_{current_date}.csv
  	file_name = user_id.to_s + "_" + Settings.EXPORT_PROMOTION + Date.today.to_s + Settings.file_type.CSV

    # initial this task
    background_job = BackgroundJob.new
    background_job.user_id = user_id
    background_job.filename = file_name
    background_job.type_view = Settings.type_view.DOWNLOAD
    background_job.status = Settings.job_status.PROCESSING
    background_job.save!
    
    @promotion_id = promotion_id

    # store csv file on server
    # path: doc/promotion_export
    path_file = Settings.export_promotion_path + file_name
    @array_results = Hash.new

    begin
      # get total for each media_category
      Settings.media_category.each do |category|
        Settings.promotions_sums.each_with_index do |sum, index|
          @array_results[category[1]+"_"+Settings.promotions_options[index]+"_total"] = DailySummaryAccount
            .where(promotion_id: @promotion_id)
            .where(media_category_id: category[0].to_s).sum(sum)
            
          Media.where(media_category_id: category[0].to_s).each_with_index do |media, index1|
            media.accounts.each_with_index do |account, index2|
              @array_results[account.account_name+"_"+Settings.promotions_options[index]] = DailySummaryAccount
                .where(promotion_id: @promotion_id)
                .where(media_category_id: category[0].to_s)
                .where(account_id: account.id).sum(sum)
            end
          end
        end
      end

      # get row data
      array_data_row = DailySummaryAccConversion.get_conversions_summary(@promotion_id)
      account_col = ["Media", "Account", "Imp", "Click", "CTR", "CPC", "CPM", "COST"]
      array_conversion = Conversion.where(promotion_id: @promotion_id)
      
      array_medium = Array.new
      array_conversion_col = Array.new
      (1..8).each do
          array_medium << ""
          array_conversion_col << ""
      end

      # initial count num
      cnt = 1

      # create csv header file
      array_conversion.each do |conversion_element|
        account_col << conversion_element.conversion_name
        array_medium << "CV#{cnt}"
        Settings.conversions_options.each do |val|
          array_conversion_col << val + "#{cnt}"
        end

        (1..9).each do
          account_col << ""
          array_medium << ""
        end

        cnt += 1
      end

      CSV.open(path_file, "wb") do |csv|

        # make header for CSV file
        csv << account_col
        csv << array_medium
        csv << array_conversion_col

        # start write content of promotion to file
        Settings.media_category.each do |media_category|
          array_media_category_total = Array.new
          array_media_category_total << media_category[1]
          array_media_category_total << "total"
          Settings.promotions_options.each do |col_val|
            array_media_category_total << @array_results[media_category[1] + "_" + col_val + "_total"]
          end
          
          array_conversion.each do |conversion_element|
            Settings.conversions_options.each do |conversion_col|
              array_media_category_total << array_data_row[media_category[1] + "_conversion#{conversion_element.id}" + "_" + conversion_col]
            end
          end
          
          # write header file to csv
          csv << array_media_category_total

          # make data row
          array_medias = Media.where(media_category_id: media_category[0])
          array_medias.each do |media|
            array_accounts = Account.where(media_id: media.id)
            array_accounts.each do |account|
              record_data = Array.new
              record_data << account.account_name

              Settings.promotions_options.each do |col_val|
                record_data << @array_results[account.account_name + "_" + col_val]
              end

              array_conversion.each do |conversion_element|
                Settings.conversions_options.each do |conversion_col|
                  record_data << array_data_row[account.account_name + "_conversion#{conversion_element.id}" + "_" + conversion_col]
                end
              end
              
              # write data row
              csv << record_data.unshift(media.media_name)
            end

          end
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
