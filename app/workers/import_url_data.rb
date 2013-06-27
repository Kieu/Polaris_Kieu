# encoding: utf-8
require 'csv'
require 'uri'

# export promotion data table from promotion screen to csv file
class ImportUrlData
  include Resque::Plugins::Status
  @queue = :import_url_data
  # define column in sv file
  LAST_MODIFIED = 0
  AD_ID = 1
  CAMPAIGN_NAME = 2
  GROUP_NAME = 3
  AD_NAME = 4
  CREATIVE_ID = 5
  COMMENT = 6
  CLICK_UNIT = 7
  SUBMIT_URL = 8
  REDIRECT_URL1 = 9
  NAME1 = 10
  RATE1 = 11
  REDIRECT_URL2 = 12
  NAME2 = 13
  RATE2 = 14
  REDIRECT_URL3 = 15
  NAME3 = 16
  RATE3 = 17
  REDIRECT_URL4 = 18
  NAME4 = 19
  RATE4 = 20
  REDIRECT_URL5 = 21
  NAME5 = 22
  RATE5 = 23

  def perform
    # get params
    promotion_id = options['promotion_id'].to_i
    account_id = options['account_id'].to_i
    media_category_id = options['media_category_id'].to_i
    media_id = options['media_id'].to_i
    type = options['type']
    user_id = options['user_id']
    client_id = options['client_id'].to_i

    I18n.locale = options['lang']
    lang = options['lang']

    # file fomat: {user_id}_import_url_{current date}.csv
    data_file = options['file']

    # get client_name, promotion_name, account_name
    promotion_name = Promotion.where(id: promotion_id).select("roman_name").first['roman_name']
    client_name = Client.where(id: client_id).select("roman_name").first['roman_name']
    account_name = Account.where(id: account_id).select("roman_name").first['roman_name']
    header_error_file = client_name + "_" + promotion_name + "_" + account_name + "_"

    # get job_id
    job_id = BackgroundJob.where(id: options['bgj_id']).select('job_id').first['job_id']

    # make header insert string sql
    insert_ad_str, insert_redirect_info_str,
        insert_redirect_url_str, insert_campaign_str, insert_group_str = make_header_insert_sql type

    # create mpv
    mpv = media_category_id.to_s(36) + "." + promotion_id.to_s(36) + "." + account_id.to_s(36)

    # file fomat: {process_id}.txt
    error_file = Settings.error_url_path + "#{job_id}.txt"
    File.open(error_file, 'w') do |error|
      begin
        if !File.exists?(data_file)
          error.write(I18n.t("error_message_url_import.unexpected_error"))
          background_job = BackgroundJob.find(options['bgj_id'])

          # false case
          background_job.status = Settings.job_status.WRONG
          background_job.filename = header_error_file + Time.now.strftime("%Y%m%d") + Settings.file_type.TXT
          background_job.filepath = error_file
          background_job.save!
          
          return
        end

        row_number = CSV.readlines(data_file).size

        if row_number > Settings.MAX_LINE_URL_IMPORT_FILE
          error.write(I18n.t("error_message_url_import.over_row"))
          background_job = BackgroundJob.find(options['bgj_id'])

          # false case
          background_job.status = Settings.job_status.WRONG
          background_job.filename = header_error_file + Time.now.strftime("%Y%m%d") + Settings.file_type.TXT
          background_job.filepath = error_file
          background_job.save!
          
          return
        end
        array_ads = Array.new
        array_redirect_info = Array.new
        array_redirect_url = Array.new
        array_ad_id_insert = Array.new
        array_ad_name_insert = Array.new
        array_double_data = Hash.new
        num = 0
        error_num = 0
        line_num = 0

        # get identifier from display_ads
        array_identifer = Array.new
        array_identifer_ads = DisplayAd.where(" del_flg = 0 and promotion_id = #{promotion_id} ")
        .select(' identifier ')
        if array_identifer_ads.count > 0
          array_identifer_ads.each do |identifier|
            array_identifer << identifier.identifier
          end
        end

        # get array creative id
        array_creative_id = Array.new
        creative_result = Creative.select('id')
        creative_result.each do |creative|
          array_creative_id << creative.id
        end

        #initial transaction
        ActiveRecord::Base.transaction do
          # read data from csv file that uploaded
          CSV.foreach(data_file) do |row|
            row_number -= 1
            line_num += 1
            if (line_num == 1)
              next
            end

            insert_camp_flg = true

            # validate data input
            row, error_num, array_identifer,
                array_ad_id_insert, array_ad_name_insert,
                array_creative_id, insert_camp_flg, display_campaign_id, 
                display_group_id = validate_data_input num, error_num, row, error, array_identifer,
                                                        array_ad_id_insert, array_ad_name_insert,
                                                        array_creative_id, line_num, array_double_data, lang, account_id
            
            # start insert data to DB
            if error_num == 0
              current_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
              comma_sql = " , "
              num += 1
              if num == 1
                comma_sql = ""
              end

              if insert_camp_flg
                # insert campaign
                campaign_obj = DisplayCampaign.new
                campaign_obj.name = row[CAMPAIGN_NAME]
                campaign_obj.client_id = client_id
                campaign_obj.promotion_id = promotion_id
                campaign_obj.account_id = account_id
                campaign_obj.create_user_id = user_id
                campaign_obj.created_at = current_time
                campaign_obj.save!

                display_campaign_id = campaign_obj.id
                # insert group
                group_obj = DisplayGroup.new
                group_obj.name = row[GROUP_NAME]
                group_obj.client_id = client_id
                group_obj.promotion_id = promotion_id
                group_obj.account_id = account_id
                group_obj.display_campaign_id = campaign_obj.id
                group_obj.create_user_id = user_id
                group_obj.created_at = current_time
                group_obj.save!

                display_group_id = group_obj.id
              end
              
              # insert group
              ad_obj = DisplayAd.new
              if row[AD_ID] != ""
                ad_obj.identifier = row[AD_ID]
              else
                ad_obj.identifier = " "
              end

              ad_obj.name = row[AD_NAME]
              ad_obj.client_id = client_id
              ad_obj.promotion_id = promotion_id
              ad_obj.account_id = account_id
              ad_obj.display_campaign_id = display_campaign_id
              ad_obj.display_group_id = display_group_id
              ad_obj.create_user_id = user_id
              ad_obj.created_at = current_time
              ad_obj.save!

              if row[AD_ID] == ""
                ad_obj.identifier = ad_obj.id
                ad_obj.save!
              end

              current_mpv = mpv + "." + ad_obj.id.to_s(36)
              
              # insert redirect infomation
              insert_redirect_info_str += "#{comma_sql} ('#{current_mpv}', #{client_id}, #{promotion_id}, #{media_category_id},
                                           #{media_id}, #{account_id}, #{display_campaign_id}, #{display_group_id}, #{ad_obj.id}, #{row[CREATIVE_ID]},
                                           #{row[CLICK_UNIT]}, '#{row[COMMENT]}', '#{current_time}', #{user_id} )

              "

              # insert url
              insert_redirect_url_str += "#{comma_sql}('#{current_mpv}', '#{row[REDIRECT_URL1]}', #{row[RATE1]}, '#{row[NAME1]}',
                                             '#{current_time}', #{user_id} ) "
              if row[REDIRECT_URL2] != ""
                insert_redirect_url_str += " , ('#{current_mpv}', '#{row[REDIRECT_URL2]}', #{row[RATE2]}, '#{row[NAME2]}',
                                             '#{current_time}', #{user_id} ) "
                num += 1
              end

              if row[REDIRECT_URL3] != ""
                insert_redirect_url_str += " , ('#{current_mpv}', '#{row[REDIRECT_URL3]}', #{row[RATE3]}, '#{row[NAME3]}',
                                             '#{current_time}', #{user_id} ) "
                num += 1
              end

              if row[REDIRECT_URL4] != ""
                insert_redirect_url_str += " , ('#{current_mpv}', '#{row[REDIRECT_URL4]}', #{row[RATE4]}, '#{row[NAME4]}',
                                             '#{current_time}', #{user_id} )  "
                num += 1
              end

              if row[REDIRECT_URL5] != ""
                insert_redirect_url_str += " , ('#{current_mpv}', '#{row[REDIRECT_URL5]}', #{row[RATE5]}, '#{row[NAME5]}',
                                             '#{current_time}', #{user_id} ) "
                num += 1
              end
              
              if num == Settings.RECORD_NUM_PER_INSERT || (row_number == 0)
                result = ActiveRecord::Base.connection.execute(insert_redirect_info_str)
                result = ActiveRecord::Base.connection.execute(insert_redirect_url_str)

                # make header insert string sql
                insert_ad_str, insert_redirect_info_str,
                    insert_redirect_url_str, insert_campaign_str, insert_group_str = make_header_insert_sql type
                num = 0
              end

            end

          end

          if error_num > 0
            background_job = BackgroundJob.find(options['bgj_id'])
            # false case
            background_job.status = Settings.job_status.WRONG
            background_job.filename = header_error_file + Time.now.strftime("%Y%m%d") + Settings.file_type.TXT
            background_job.filepath = error_file
            background_job.save!
            raise ActiveRecord::Rollback
          end
        end
        # commit transation
        background_job = BackgroundJob.find(options['bgj_id'])
        if error_num == 0
          # false case
          background_job.status = Settings.job_status.SUCCESS
          background_job.filepath = data_file
        else
          background_job.status = Settings.job_status.WRONG
          background_job.filename = header_error_file + Time.now.strftime("%Y%m%d") + Settings.file_type.TXT
          background_job.filepath = error_file

        end
        background_job.save!
        if error_num == 0
          File.delete(error_file)
        end

      rescue
        background_job = BackgroundJob.find(options['bgj_id'])
        # false case
        background_job.status = Settings.job_status.WRONG
        background_job.filename = header_error_file + Time.now.strftime("%Y%m%d") + Settings.file_type.TXT
        background_job.filepath = error_file
        background_job.save!
        error.write(I18n.t("error_message_url_import.unexpected_error"))
      end
    end
    File.delete(data_file)
  end

  private
  def is_numeric?(obj)
    obj.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
  end

  def valid?(url)
    uri = URI.parse(url)
    uri.kind_of?(URI::HTTP)
  rescue URI::InvalidURIError
    false
  end

  def make_header_insert_sql type
    update_str = " , created_at, create_user_id "
    if (type == 'update')
      update_str = " , updated_at, update_user_id "
    end

    insert_ad_str = "
                  insert into display_ads
                   (identifier, name, client_id, promotion_id, account_id, display_campaign_id,
                          display_group_id, del_flg #{update_str} )
                  values

                 "

    insert_redirect_info_str = "
                  insert into redirect_informations 
                   (mpv, client_id, promotion_id, media_category_id, media_id, account_id,
                          campaign_id, group_id, unit_id, creative_id, click_unit,
                          comment #{update_str} )
                  values
                  "

    insert_redirect_url_str = "
                  insert into redirect_urls 
                   (mpv, url, rate, name #{update_str} )
                  values

                  "
    insert_campaign_str = "
                  insert into display_campaigns 
                   (name, client_id, promotion_id, account_id,
                          del_flg #{update_str} )
                  values

                  "

    insert_group_str = "
                  insert into display_groups 
                   (name, client_id, promotion_id, account_id, display_campaign_id,
                          del_flg #{update_str} )
                  values

                  "
    return insert_ad_str, insert_redirect_info_str,
        insert_redirect_url_str, insert_campaign_str,
        insert_group_str
  end


  def validate_data_input num, error_num, row, error,
      array_identifer, array_ad_id_insert,
      array_ad_name_insert, array_creative_id, line_num, array_double_data, lang, account_id

    insert_camp_flg = true
    insert_group_flg = true
    display_campaign_id = false
    display_group_id = false

    # LAST_MODIFIED field
    row[LAST_MODIFIED] = row[LAST_MODIFIED].to_s.strip

    line_en = I18n.t("error_message_url_import.line")
    line_jp = I18n.t("error_message_url_import.line")
    enter_key = I18n.t("error_message_url_import.enter_key")

    if lang == 'en'
      line_jp = ""
    else
      line_en = ""
    end

    # AD_ID field
    row[AD_ID] = row[AD_ID].to_s.strip
    if row[AD_ID] != ""
      if row[AD_ID].length > 255
        error_num += 1
        error.write("#{line_en} #{line_num}#{line_jp}: " + I18n.t("error_message_url_import.ad_too_long") + "#{enter_key}")
      end

      if array_identifer.include?(row[AD_ID])
        error_num += 1
        error.write("#{line_en} #{line_num}#{line_jp}: " + I18n.t("error_message_url_import.ad_id_already_used") + "#{enter_key}")
      end

      if is_numeric? row[AD_ID] != true
        error_num += 1
        error.write("#{line_en} #{line_num}#{line_jp}: " + I18n.t("error_message_url_import.ad_id_invalid") + "#{enter_key}")
      end

      if array_ad_id_insert.count > 0 && array_ad_id_insert.include?(row[AD_ID])
        error_num += 1
        error.write("#{line_en} #{line_num}#{line_jp}: " + I18n.t("error_message_url_import.ad_id_used_same_file") + "#{enter_key}")
      end

      array_ad_id_insert << row[AD_ID]

    else

    end

    # CAMPAIGN_NAME field
    row[CAMPAIGN_NAME] = row[CAMPAIGN_NAME].to_s.strip
    if row[CAMPAIGN_NAME] != ""
      if row[CAMPAIGN_NAME].length > 255
        error_num += 1
        error.write("#{line_en} #{line_num}#{line_jp}: " + I18n.t("error_message_url_import.campaign_too_long") + "#{enter_key}")
      end

      array_campaigns = DisplayCampaign.where(" name = '#{row[CAMPAIGN_NAME]}' and account_id = #{account_id}").select('id')
      if array_campaigns.count > 0
        insert_camp_flg = false
        display_campaign_id = array_campaigns.first['id']
      end
    else
      error_num += 1
      error.write("#{line_en} #{line_num}#{line_jp}: " + I18n.t("error_message_url_import.campaign_name_not_type") + "#{enter_key}")

    end

    # GROUP_NAME
    row[GROUP_NAME] = row[GROUP_NAME].to_s.strip
    if row[GROUP_NAME] != ""
      if row[GROUP_NAME].length > 255
        error_num += 1
        error.write("#{line_en} #{line_num}#{line_jp}: " + I18n.t("error_message_url_import.group_name_too_long") + "#{enter_key}")
      end

      if !insert_camp_flg
        array_groups = DisplayGroup.where(" name = '#{row[GROUP_NAME]}' and display_campaign_id = #{display_campaign_id}").select('id')
        insert_group_flg = false
        display_group_id = array_groups.first['id']
      end
    else
      error_num += 1
      error.write("#{line_en} #{line_num}#{line_jp}: " + I18n.t("error_message_url_import.group_name_not_type") + "#{enter_key}")

    end

    # AD_NAME
    row[AD_NAME] = row[AD_NAME].to_s.strip
    if row[AD_NAME] != ""
      if row[AD_NAME].length > 255
        error_num += 1
        error.write("#{line_en} #{line_num}#{line_jp}: " + I18n.t("error_message_url_import.ad_name_too_long") + "#{enter_key}")
      end

      if !insert_group_flg
        array_ads = DisplayAd.where(" name = '#{row[AD_NAME]}' and display_group_id = #{display_group_id}").select('id')
        if array_ads.count > 0
          error_num += 1
          error.write("#{line_en} #{line_num}#{line_jp}: " + I18n.t("error_message_url_import.ad_name_already_used") + "#{enter_key}")
        end
      end

      array_ad_name_insert << row[AD_NAME]
    else
      error_num += 1
      error.write("#{line_en} #{line_num}#{line_jp}: " + I18n.t("error_message_url_import.ad_name_not_type") + "#{enter_key}")

    end

    # check double [Campaign name] [group name] [ad name]
    key_str = "#{row[CAMPAIGN_NAME]}_#{row[GROUP_NAME]}_#{row[AD_NAME]}"

    if !array_double_data[key_str]
      array_double_data[key_str] = line_num.to_s
    else
      array_double_data[key_str] += "," + line_num.to_s
      error_num += 1
      error.write("#{line_en} #{array_double_data[key_str]}#{line_jp}: " + I18n.t("error_message_url_import.name_overlapped") + "#{enter_key}")
    end

    # CREATIVE_ID field
    row[CREATIVE_ID] = row[CREATIVE_ID].to_s.strip
    if row[CREATIVE_ID] != ""
      if !is_numeric? row[CREATIVE_ID]
        error_num += 1
        error.write("#{line_en} #{line_num}#{line_jp}: " + I18n.t("error_message_url_import.creative_id_half_width") + "#{enter_key}")
      end

      if row[CREATIVE_ID].length > 20
        error_num += 1
        error.write("#{line_en} #{line_num}#{line_jp}: " + I18n.t("error_message_url_import.creative_id_too_long") + "#{enter_key}")
      end

      if !array_creative_id.include?(row[CREATIVE_ID].to_i)
        error_num += 1
        error.write("#{line_en} #{line_num}#{line_jp}: " + I18n.t("error_message_url_import.creative_id_not_exist") + "#{enter_key}")
      end

    end

    # COMMENT field
    row[COMMENT] = row[COMMENT].to_s.strip

    # CLICK_UNIT field
    row[CLICK_UNIT] = row[CLICK_UNIT].to_s.strip
    if row[CLICK_UNIT] != ""
      if !is_numeric? row[CLICK_UNIT]
        error_num += 1
        error.write("#{line_en} #{line_num}#{line_jp}: " + I18n.t("error_message_url_import.unit_click_price_half_width") + "#{enter_key}")
      end
    end

    # SUBMIT URL field
    row[SUBMIT_URL] = row[SUBMIT_URL].to_s.strip
    if row[SUBMIT_URL] != ""
      error_num += 1
      error.write("#{line_en} #{line_num}#{line_jp}: " + I18n.t("error_message_url_import.leave_url_column_blank") + "#{enter_key}")
    end

    # REDIRECT_URL1 ==============================================
    row[REDIRECT_URL1] = row[REDIRECT_URL1].to_s.strip
    if row[REDIRECT_URL1] == ""
      error_num += 1
      error.write("#{line_en} #{line_num}#{line_jp}: " + I18n.t("error_message_url_import.url_not_specified") + "1#{enter_key}")
    end

    #NAME1
    row[NAME1] = row[NAME1].to_s.strip
    if row[NAME1] != ""
      if row[NAME1].length > 255
        error_num += 1
        if lang == 'en'
          error.write("Line #{line_num}: Title 1 needs to be less than 255 letters.\n")
        else
          error.write("#{line_num}#{line_jp}:タイトル1は文字数の上限255文字を超えています。\n")
        end
      end
    else
      error_num += 1
      if lang == 'en'
        error.write("Line #{line_num}: Title 1 is not typed.\n")
      else
        error.write("#{line_num}#{line_jp}:タイトル1が記入されておりません。\n")
      end
    end

    #RATE1
    row[RATE1] = row[RATE1].to_s.strip
    if row[RATE1] != ""
      if !is_numeric? row[RATE1]
        error_num += 1
        if lang == 'en'
          error.write("Line #{line_num}: Please type Transition rate1 with half-width characters. \n")
        else
          error.write("#{line_num}#{line_jp}:遷移割合1は半角数字で入力してください。\n")
        end
        
      end
    else
      error_num += 1
      if lang == 'en'
        error.write("Line #{line_num}: RATE 1 is not typed.\n")
      else
        error.write("#{line_num}#{line_jp}:遷移割合1が記入されておりません。\n")
      end
      
    end

    # REDIRECT_URL2 ==============================================
    row[REDIRECT_URL2] = row[REDIRECT_URL2].to_s.strip

    #NAME2
    row[NAME2] = row[NAME2].to_s.strip
    if row[NAME2] != ""
      if row[NAME2].length > 255
        error_num += 1
        if lang == 'en'
          error.write("Line #{line_num}: Title 2 needs to be less than 255 letters.\n")
        else
          error.write("#{line_num}#{line_jp}:タイトル2は文字数の上限255文字を超えています。\n")
        end
      end
    end

    #RATE2
    row[RATE2] = row[RATE2].to_s.strip
    if row[RATE2] != ""
      if !is_numeric? row[RATE2]
        error_num += 1
        if lang == 'en'
          error.write("Line #{line_num}: Please type Transition rate2 with half-width characters.\n")
        else
          error.write("#{line_num}#{line_jp}:遷移割合2は半角数字で入力してください。\n")
        end
      end
    end

    if !((row[REDIRECT_URL2] != "") && (row[NAME2] != "") && (row[RATE2] != "")) &&
        !((row[REDIRECT_URL2] == "") && (row[NAME2] == "") && (row[RATE2] == ""))
      error_num += 1
      if lang == 'en'
        error.write("Line #{line_num}: REDIRECT_URL2, NAME2, RATE2 have typed together or blank together.\n")
      else
        error.write("#{line_num}#{line_jp}:リンク先２、タイトル２、遷移割合２は一緒に入力必須です。もしくは一緒に空欄にしてください。\n")
      end
      
    end

    # REDIRECT_URL3 ==============================================
    row[REDIRECT_URL3] = row[REDIRECT_URL3].to_s.strip

    #NAME3
    row[NAME3] = row[NAME3].to_s.strip
    if row[NAME3] != ""
      if row[NAME3].length > 255
        error_num += 1
        if lang == 'en'
          error.write("Line #{line_num}: Title 3 needs to be less than 255 letters.\n")
        else
          error.write("#{line_num}#{line_jp}:タイトル3は文字数の上限255文字を超えています。\n")
        end
      end
    end

    #RATE3
    row[RATE3] = row[RATE3].to_s.strip
    if row[RATE3] != ""
      if !is_numeric? row[RATE3]
        error_num += 1
        if lang == 'en'
          error.write("Line #{line_num}: Please type Transition rate3 with half-width characters.\n")
        else
          error.write("#{line_num}#{line_jp}:遷移割合3は半角数字で入力してください。\n")
        end
      end
    end

    if !((row[REDIRECT_URL3] != "") && (row[NAME3] != "") && (row[RATE3] != "")) &&
        !((row[REDIRECT_URL3] == "") && (row[NAME3] == "") && (row[RATE3] == ""))
      error_num += 1
      if lang == 'en'
        error.write("Line #{line_num}: REDIRECT_URL3, NAME3, RATE3 have typed together or blank together.\n")
      else
        error.write("#{line_num}#{line_jp}:リンク先3、タイトル3、遷移割合3は一緒に入力必須です。もしくは一緒に空欄にしてください。\n")
      end
      
    end

    # REDIRECT_URL4 ==============================================
    row[REDIRECT_URL4] = row[REDIRECT_URL4].to_s.strip

    #NAME4
    row[NAME4] = row[NAME4].to_s.strip
    if row[NAME4] != ""
      if row[NAME4].length > 255
        error_num += 1
        if lang == 'en'
          error.write("Line #{line_num}: Title 4 needs to be less than 255 letters.\n")
        else
          error.write("#{line_num}#{line_jp}:タイトル4は文字数の上限255文字を超えています。\n")
        end
        
      end
    end

    #RATE4
    row[RATE4] = row[RATE4].to_s.strip
    if row[RATE4] != ""
      if !is_numeric? row[RATE4]
        error_num += 1
        if lang == 'en'
          error.write("Line #{line_num}: Please type Transition rate4 with half-width characters.\n")
        else
          error.write("#{line_num}#{line_jp}:遷移割合4は半角数字で入力してください。\n")
        end
        
      end
    end

    if !((row[REDIRECT_URL4] != "") && (row[NAME4] != "") && (row[RATE4] != "")) &&
        !((row[REDIRECT_URL4] == "") && (row[NAME4] == "") && (row[RATE4] == ""))
      error_num += 1
      if lang == 'en'
        error.write("Line #{line_num}: REDIRECT_URL4, NAME4, RATE4 have typed together or blank together.\n")
      else
        error.write("#{line_num}#{line_jp}:リンク先4、タイトル4、遷移割合4は一緒に入力必須です。もしくは一緒に空欄にしてください。\n")
      end
      
    end
    # REDIRECT_URL5 ==============================================
    row[REDIRECT_URL5] = row[REDIRECT_URL5].to_s.strip

    #NAME5
    row[NAME5] = row[NAME5].to_s.strip
    if row[NAME5] != ""
      if row[NAME5].length > 255
        error_num += 1
        if lang == 'en'
          error.write("Line #{line_num}: Title 5 needs to be less than 255 letters.\n")
        else
          error.write("#{line_num}#{line_jp}:タイトル5は文字数の上限255文字を超えています。\n")
        end
        
      end
    end

    #RATE5
    row[RATE5] = row[RATE5].to_s.strip
    if row[RATE5] != ""
      if !is_numeric? row[RATE5]
        error_num += 1
        if lang == 'en'
          error.write("Line #{line_num}: Please type Transition rate5 with half-width characters.\n")
        else
          error.write("#{line_num}#{line_jp}:遷移割合5は半角数字で入力してください。\n")
        end
        
      end
    end

    if !((row[REDIRECT_URL5] != "") && (row[NAME5] != "") && (row[RATE5] != "")) &&
        !((row[REDIRECT_URL5] == "") && (row[NAME5] == "") && (row[RATE5] == ""))
      error_num += 1
      if lang == 'en'
        error.write("Line #{line_num}: REDIRECT_URL5, NAME5, RATE5 have typed together or blank together.\n")
      else
        error.write("#{line_num}#{line_jp}:リンク先5、タイトル5、遷移割合5は一緒に入力必須です。もしくは一緒に空欄にしてください。\n")
      end
      
    end

    # check total rate is 100
    if (row[RATE5].to_i + row[RATE4].to_i + row[RATE3].to_i + row[RATE2].to_i + row[RATE1].to_i) != 100
      error_num += 1
      error.write("#{line_en} #{line_num}#{line_jp}: " + I18n.t("error_message_url_import.transition_rake_altogether") + "#{enter_key}")
    end

    return row, error_num, array_identifer, array_ad_id_insert, array_ad_name_insert, array_creative_id, insert_camp_flg, display_campaign_id, display_group_id
  end

end
