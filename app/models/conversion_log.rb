class ConversionLog < ActiveRecord::Base
  establish_connection :log_db_development

    FIELD = "conversion_utime, conversion_id, conversion_category, conversion_type, repeat_flg,
              approval_status, media_id,account_id, campaign_id,ad_group_id, ad_id, click_time, verify,
              suid, session_id, device_category,  repeat_proccessed_flg,'OK' as log_state, sales, profit, volume, others, null as error_message, null as error_log_view"
    FIELD_ERROR = "conversion_utime, conversion_id, conversion_category, conversion_type, null as repeat_flg,
              approval_status, media_id,account_id, campaign_id,ad_group_id, ad_id, click_time, verify,
              suid, session_id, device_category, null as repeat_proccessed_flg, 'NG' as log_state , sales, profit, volume, others, null as error_message, null as error_log_view"

    FIELD_ORGANIC = "conversion_time as conversion_utime, conversion_id, conversion_category,null as conversion_type, null as repeat_flg,
              null as approval_status, null as media_id,null as account_id, null as campaign_id,null as ad_group_id, null as ad_id, null as click_time, verify,
              suid, null as session_id, null as device_category, null as repeat_proccessed_flg,'OGANIC' as log_state, sales, profit, volume, others, null as error_message, null as error_log_view"
    
  def self.get_all_logs id, page, rp, cv_id, media_category_id, account_id, start_date, end_date, show_error, sortname, sortorder
    start = (page.to_i-1) * rp.to_i
    set_table_name "conversion_#{id}_logs"  
    where_clause = ""
    params = [start_date, end_date]
    params1 = [start_date, end_date]
    if(cv_id.present?)  
      where_clause += " AND conversion_id = ?"
      params += [cv_id]
      params1 += [cv_id]
    end
    if(media_category_id.present?)  
      where_clause += " AND media_category_id = ?"
      params += [media_category_id]
      params1 += [media_category_id]
    end
    if(account_id.present?)  
      where_clause += " AND account_id = ?"
      params += [account_id]
      params1 += [account_id]
    end
    if show_error=="1"
      sql_str = "(select #{FIELD} from conversion_#{id}_logs  where DATE_FORMAT(created_at, '%Y/%m/%d') BETWEEN ? AND ? #{where_clause}) union all
                                       (select #{FIELD_ERROR} from conversion_error_#{id}_logs where DATE_FORMAT(created_at, '%Y/%m/%d') BETWEEN ? AND ? #{where_clause}) union all
                                       (select #{FIELD_ORGANIC} from conversion_organic_#{id}_logs)

                                       ORDER BY #{sortname} #{sortorder} LIMIT #{start}, #{rp} "
                                        
      params += params1
    else
      sql_str = "(select #{FIELD} from conversion_#{id}_logs  where DATE_FORMAT(created_at, '%Y/%m/%d') BETWEEN ? AND ? #{where_clause}) union all
                                       (select #{FIELD_ORGANIC} from conversion_organic_#{id}_logs)
                                       ORDER BY #{sortname} #{sortorder} LIMIT #{start}, #{rp} "
                                        
    end                                    
            
    @logs = ConversionLog.find_by_sql([sql_str] + params)
  end

  def self.get_count  id, cv_id, media_category_id, account_id, start_date, end_date, show_error
    set_table_name "conversion_#{id}_logs" 
    
    set_table_name "conversion_#{id}_logs"  
    where_clause = ""
    params = [start_date, end_date]
    params1 = [start_date, end_date]
    if(cv_id.present?)  
      where_clause += " AND conversion_id = ?"
      params += [cv_id]
      params1 += [cv_id]
    end
    if(media_category_id.present?)  
      where_clause += " AND media_category_id = ?"
      params += [media_category_id]
      params1 += [media_category_id]
    end
    if(account_id.present?)  
      where_clause += " AND account_id = ?"
      params += [account_id]
      params1 += [account_id]
    end
    if show_error=="1"
      sql_str = "select count(*) as cnt from (select id from conversion_#{id}_logs  where DATE_FORMAT(created_at, '%Y/%m/%d') BETWEEN ? AND ? #{where_clause} union all
                 select id from conversion_error_#{id}_logs where DATE_FORMAT(created_at, '%Y/%m/%d') BETWEEN ? AND ? #{where_clause} union all
                 select id from conversion_organic_#{id}_logs group by id) as logs"

      params += params1
    else
      sql_str = "select count(*) as cnt from (select id from conversion_#{id}_logs  where DATE_FORMAT(created_at, '%Y/%m/%d') BETWEEN ? AND ? #{where_clause} union all
                 select id from conversion_organic_#{id}_logs group by id) as logs"
    end                            
    @count = ConversionLog.find_by_sql([sql_str] + params)
    @count[0]["cnt"]
  end
end