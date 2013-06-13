require 'csv'
require 'uri'

# export promotion data table from promotion screen to csv file
class ImportUrlData
  @queue = :default
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

  def self.perform
    # get params
    promotion_id = 1
    account_id = 1
    media_category_id = 1
    redirect_infomation_id = 1
    media_id = 1
    type = "insert"
    user_id = 1
    client_id = 1
 
    # make header insert string sql
    insert_ad_str, insert_redirect_info_str, 
    insert_redirect_url_str, insert_campaign_str, insert_group_str =  make_header_insert_sql type

    # create mpv
    mpv = media_category_id.to_s(36) + "." + promotion_id.to_s(36) + "." + account_id.to_s(36) +
                            "." + redirect_infomation_id.to_s(36)

    # file fomat: {user_id}_import_url_{current date}.csv
    data_file = 'doc/url/import_url/1_url_data_20130612.csv'

     # file fomat: {process_id}_error.txt
     error_file = 'doc/url/error_message/111_error.txt'
     File.open(error_file, 'w') do |error|
       begin 
         if !File.exists?(data_file)
           error.write("Can't import Url data!")
           exit
         end

         array_ads = Array.new
         array_redirect_info = Array.new
         array_redirect_url = Array.new
         array_ad_id_insert = Array.new
         array_ad_name_insert = Array.new
         num = 1
         error_num = 0

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
             # validate data input
             row, error_num, array_identifer, 
             array_ad_id_insert, array_ad_name_insert, 
             array_creative_id = validate_data_input num, error_num, row, error, array_identifer, 
                                                     array_ad_id_insert, array_ad_name_insert, 
                                                     array_creative_id
             # start insert data to DB
             if error_num == 0
               current_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
               comma_sql = " , "
               if num == 10
                 comma_sql = ""
               end

               insert_campaign_str += "('#{row[CAMPAIGN_NAME]}', #{client_id}, #{promotion_id},
                                        #{account_id}, 0, '#{current_time}', #{user_id} ) #{comma_sql}

                                       "

               insert_group_str += "('#{row[GROUP_NAME]}', #{client_id}, #{promotion_id},
                                        #{account_id}, #{num + 10}, 0, '#{current_time}', #{user_id} ) #{comma_sql}

                                       "

               insert_ad_str += "('#{row[AD_ID]}', '#{row[AD_NAME]}',#{client_id}, #{promotion_id},
                                        #{account_id}, #{num + 10}, #{num + 15}, 0, '#{current_time}', #{user_id} ) #{comma_sql}

                                       "

               insert_redirect_info_str += "('#{mpv}', #{client_id}, #{promotion_id}, #{media_category_id},
                                           #{media_id}, #{account_id}, #{num + 10}, #{num + 11}, #{num + 12}, 1,
                                           #{row[CLICK_UNIT]}, '#{row[COMMENT]}', 0, '#{current_time}', #{user_id} ) #{comma_sql}

                                       "

               insert_redirect_url_str += "('#{mpv}', '#{row[REDIRECT_URL1]}', #{row[RATE1]}, '#{row[NAME1]}',
                                             '#{current_time}', #{user_id} ) #{comma_sql}

                                            "
               
               if num == 10
                 result = ActiveRecord::Base.connection.execute(insert_campaign_str)
                 result = ActiveRecord::Base.connection.execute(insert_group_str)
                 result = ActiveRecord::Base.connection.execute(insert_ad_str)
                 result = ActiveRecord::Base.connection.execute(insert_redirect_info_str)
                 result = ActiveRecord::Base.connection.execute(insert_redirect_url_str)
               end

             end

             num += 1

           end
           
           if error_num > 0
             raise ActiveRecord::Rollback
           end
         end
         # commit transation
         
       rescue
         error.write("Can't import Url data!")
       end
     end

     #CSV.foreach(path) do |row|
       #binding.pry
     #end  
  end

  def self.is_numeric?(obj) 
    obj.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
  end

  def self.valid?(url)
    uri = URI.parse(url)
    uri.kind_of?(URI::HTTP)
  rescue URI::InvalidURIError
    false
  end

  def self.make_header_insert_sql type
    update_str = " , create_at, create_user_id "
    if(type == 'update')
      update_str = " , update_at, update_user_id "
    end

    insert_ad_str = "
                  insert into display_ads
                   (identifier, name, client_id, promotion_id, account_id, display_campaign_id,
                          display_group_id, del_flg #{update_str} )
                  values

                 "

    insert_redirect_info_str = "
                  insert into redirect_infomations 
                   (mpv, client_id, promotion_id, media_category_id, media_id, account_id,
                          campaign_id, group_id, unit_id, creative_id, click_unit,
                          comment, del_flg #{update_str} )
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


  def self.validate_data_input num, error_num, row, error, 
                               array_identifer, array_ad_id_insert, 
                               array_ad_name_insert, array_creative_id
     
     # LAST_MODIFIED field
     if row[LAST_MODIFIED].to_s.strip == ""
      error_num += 1
      error.write("At row #{num}, column LAST_MODIFIED can't blank.")
     end
     
     # AD_ID field
     row[AD_ID] = row[AD_ID].to_s.strip
     if row[AD_ID] != ""
       if row[AD_ID].length > 255
         error_num += 1
         error.write(" Over > 255 ")
       end

       if array_identifer.include?(row[AD_ID].to_i)
         error_num += 1
         error.write("At row #{num}, column AD_ID has already existed.")
       end

       if is_numeric? row[AD_ID] != true
         error_num += 1
         error.write(" not integer .")
       end

       if array_ad_id_insert.count > 0 && array_ad_id_insert.include?(row[AD_ID].to_i)
         error_num += 1
         error.write(" trung voi id o cac hang ghi truoc .")
       end

       array_ad_id_insert << row[AD_ID]

     else
       
     end
     
     # CAMPAIGN_NAME field
     row[CAMPAIGN_NAME] = row[CAMPAIGN_NAME].to_s.strip
     if row[CAMPAIGN_NAME] != ""
        if row[CAMPAIGN_NAME].length > 255
          error_num += 1
          error.write(" campaign name over > 255 ")
        end

     else
        error_num += 1
        error.write(" campaign name blank ")

     end
     
     # GROUP_NAME
     row[GROUP_NAME] = row[GROUP_NAME].to_s.strip
     if row[GROUP_NAME] != ""
        if row[GROUP_NAME].length > 255
          error_num += 1
          error.write(" GROUP_NAME over > 255 ")
        end
     else
        error_num += 1
        error.write(" GROUP_NAME blank ")

     end

     # AD_NAME
     row[AD_NAME] = row[AD_NAME].to_s.strip
     if row[AD_NAME] != ""
        if row[AD_NAME].length > 255
          error_num += 1
          error.write(" AD_NAME over > 255 ")
        end
        
        if array_ad_name_insert.count > 0 && array_ad_name_insert.include?(row[AD_NAME])
          error_num += 1
          error.write(" trung voi ad_name o cac ban ghi truoc .")
        end

        array_ad_name_insert << row[AD_NAME]
     else
        error_num += 1
        error.write(" AD_NAME blank ")

     end

     # CREATIVE_ID field
     row[CREATIVE_ID] = row[CREATIVE_ID].to_s.strip
     if row[CREATIVE_ID] != ""
       if !is_numeric? row[CREATIVE_ID]
         error_num += 1
         error.write(" CREATIVE_ID is not number.")
       end
       
       if row[CREATIVE_ID].length > 20
          error_num += 1
          error.write(" CREATIVE_ID over > 20 ")
       end

       if !array_creative_id.include?(row[CREATIVE_ID].to_i)
         error_num += 1
         error.write("At row #{num}, column CREATIVE_ID incorrect.")
       end
       
     end

     # COMMENT field
     row[COMMENT] = row[COMMENT].to_s.strip

     # CLICK_UNIT field
     row[CLICK_UNIT] = row[CLICK_UNIT].to_s.strip
     if row[CLICK_UNIT] != ""
       if !is_numeric? row[CLICK_UNIT]
         error_num += 1
         error.write("At row #{num}, column CLICK_UNIT is not number.")
       end
     end

     # SUBMIT URL field
     row[SUBMIT_URL] = row[SUBMIT_URL].to_s.strip
     if row[SUBMIT_URL] != ""
       error_num += 1
       error.write(" SUBMIT_URL bi nhap gi do ")
     end

     # REDIRECT_URL1 ==============================================
     row[REDIRECT_URL1] = row[REDIRECT_URL1].to_s.strip
     if row[REDIRECT_URL1] != ""
       if !valid? row[REDIRECT_URL1]
         error_num += 1
         error.write(" REDIRECT_URL1 khong dung ")
       end
     else
       error_num += 1
       error.write(" REDIRECT_URL1 khong duoc rong ")
     end

     #NAME1
     row[NAME1] = row[NAME1].to_s.strip
     if row[NAME1] != ""
       if row[NAME1].length > 255
         error_num += 1
         error.write(" NAME1 over > 255 ")
       end
     else
       error_num += 1
       error.write(" NAME1 khong duoc rong ")
     end

     #RATE1
     row[RATE1] = row[RATE1].to_s.strip
     if row[RATE1] != ""
       if !is_numeric? row[RATE1]
         error_num += 1
         error.write("At row #{num}, column RATE1 is not number.")
       end
     else
       error_num += 1
       error.write(" RATE1 khong duoc rong ")
     end

     # REDIRECT_URL2 ==============================================
     row[REDIRECT_URL2] = row[REDIRECT_URL2].to_s.strip
     if row[REDIRECT_URL2] != ""
       if !valid? row[REDIRECT_URL2]
         error_num += 1
         error.write(" REDIRECT_URL2 khong dung ")
       end
     end
     
     
     #NAME2
     row[NAME2] = row[NAME2].to_s.strip
     if row[NAME2] != ""
       if row[NAME2].length > 255
         error_num += 1
         error.write(" NAME2 over > 255 ")
       end
     end

     #RATE2
     row[RATE2] = row[RATE2].to_s.strip
     if row[RATE2] != ""
       if !is_numeric? row[RATE2]
         error_num += 1
         error.write("At row #{num}, column RATE2 is not number.")
       end
     end

     # REDIRECT_URL3 ==============================================
     row[REDIRECT_URL3] = row[REDIRECT_URL3].to_s.strip
     if row[REDIRECT_URL3] != ""
       if !valid? row[REDIRECT_URL3]
         error_num += 1
         error.write(" REDIRECT_URL3 khong dung ")
       end
     end
     
     
     #NAME3
     row[NAME3] = row[NAME3].to_s.strip
     if row[NAME3] != ""
       if row[NAME3].length > 255
         error_num += 1
         error.write(" NAME3 over > 255 ")
       end
     end

     #RATE3
     row[RATE3] = row[RATE3].to_s.strip
     if row[RATE3] != ""
       if !is_numeric? row[RATE3]
         error_num += 1
         error.write("At row #{num}, column RATE3 is not number.")
       end
     end

     # REDIRECT_URL4 ==============================================
     row[REDIRECT_URL4] = row[REDIRECT_URL4].to_s.strip
     if row[REDIRECT_URL4] != ""
       if !valid? row[REDIRECT_URL4]
         error_num += 1
         error.write(" REDIRECT_URL4 khong dung ")
       end
     end
     
     
     #NAME4
     row[NAME4] = row[NAME4].to_s.strip
     if row[NAME4] != ""
       if row[NAME4].length > 255
         error_num += 1
         error.write(" NAME4 over > 255 ")
       end
     end

     #RATE4
     row[RATE4] = row[RATE4].to_s.strip
     if row[RATE4] != ""
       if !is_numeric? row[RATE4]
         error_num += 1
         error.write("At row #{num}, column RATE4 is not number.")
       end
     end

     # REDIRECT_URL5 ==============================================
     row[REDIRECT_URL5] = row[REDIRECT_URL5].to_s.strip
     if row[REDIRECT_URL5] != ""
       if !valid? row[REDIRECT_URL5]
         error_num += 1
         error.write(" REDIRECT_URL5 khong dung ")
       end
     end
     
     
     #NAME5
     row[NAME5] = row[NAME5].to_s.strip
     if row[NAME5] != ""
       if row[NAME5].length > 255
         error_num += 1
         error.write(" NAME5 over > 255 ")
       end
     end

     #RATE5
     row[RATE5] = row[RATE5].to_s.strip
     if row[RATE5] != ""
       if !is_numeric? row[RATE5]
         error_num += 1
         error.write("At row #{num}, column RATE5 is not number.")
       end
     end


     return row, error_num, array_identifer, array_ad_id_insert, array_ad_name_insert, array_creative_id
  end

end
