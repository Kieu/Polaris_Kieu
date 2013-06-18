class ClickLog < ActiveRecord::Base
  establish_connection :log_db_development
  attr_accessible :access_track_server, :account_id, :group_id, :unit_id,
                  :campaign_id, :click_utime, :click_url, :click_ymd, :creative_id,
                  :device_category, :mark, :media_category_id, :media_id, :media_session_id, :mpv,
                  :redirect_infomation_id, :redirect_url, :redirect_url_id, :referrer, :remote_ip,
                  :request_uri, :session_id, :user_agent, :verify, :error_code, :state

  def self.get_all_logs id, page, rp, sortname, sortorder, media_category_id, account_id, start_date, end_date, show_error
    set_table_name "click_#{id}_logs"
    start = (page.to_i-1) * rp.to_i
    
    params = [start_date, end_date]
    where_clause = ""
    
    if media_category_id.present?
      where_clause += " AND media_category_id=?"
      params += [media_category_id.to_i]
    end
    if account_id.present?
      where_clause += " AND account_id=? "
      params += [account_id.to_i]
    end
    
    if (show_error == "1")
      sql_str = "select *, null as error_code, 'OK' as state from click_#{id}_logs
               where DATE_FORMAT(created_at, '%Y/%m/%d') BETWEEN ? AND ? #{where_clause} union all
               select *, 'NG' as state from click_error_#{id}_logs
               where DATE_FORMAT(created_at, '%Y/%m/%d') BETWEEN ? AND ? #{where_clause}
               ORDER BY media_category_id, #{sortname} #{sortorder} LIMIT #{start}, #{rp} "
      params += params
    else
      sql_str = "select *, null as error_code, 'OK' as state from click_#{id}_logs
               where DATE_FORMAT(created_at, '%Y/%m/%d') BETWEEN ? AND ? #{where_clause}
               ORDER BY media_category_id, #{sortname} #{sortorder} LIMIT #{start}, #{rp} "
    end
    @logs = ClickLog.find_by_sql([sql_str] + params)
  end         
  
  def self.get_logs id, media_category_id, account_id, start_date, end_date, show_error
    set_table_name "click_#{id}_logs"
    
    params = [start_date, end_date]
    where_clause = ""
    
    if media_category_id.present?
      where_clause += " AND media_category_id=?"
      params += [media_category_id.to_i]
    end
    if account_id.present?
      where_clause += " AND account_id=? "
      params += [account_id.to_i]
    end
    
    if (show_error == "1")
      sql_str = "select *, null as error_code, 'OK' as state from click_#{id}_logs
                 where DATE_FORMAT(created_at, '%Y/%m/%d') BETWEEN ? AND ? #{where_clause} union all
                 select *, 'NG' as state from click_error_#{id}_logs
                 where DATE_FORMAT(created_at, '%Y/%m/%d') BETWEEN ? AND ? #{where_clause}
               ORDER BY media_category_id, click_utime "
      params += params
    else
      sql_str = "select *, '0' as error_code, 'OK' as state from click_#{id}_logs
               where DATE_FORMAT(created_at, '%Y/%m/%d') BETWEEN ? AND ? #{where_clause}
               ORDER BY media_category_id, click_utime"
    end
    @logs = ClickLog.find_by_sql([sql_str] + params)
  end         
  
  
  def self.get_log_count id, media_category_id, account_id, start_date, end_date, show_error
    
    params = [start_date, end_date]
    where_clause = ""
    
    if media_category_id.present?
      where_clause += " AND media_category_id=?"
      params += [media_category_id.to_i]
    end
    if account_id.present?
      where_clause += " AND account_id=? "
      params += [account_id.to_i]
    end
    if (show_error == "1")
      sql_str = "select count(*) as cnt from (select id from click_#{id}_logs 
               where DATE_FORMAT(created_at, '%Y/%m/%d') BETWEEN ? AND ? #{where_clause} union all
               select id from click_error_#{id}_logs 
               where DATE_FORMAT(created_at, '%Y/%m/%d') BETWEEN ? AND ? #{where_clause} group by id) as logs "
      params += params
    else
      sql_str = "select count(id) as cnt from click_#{id}_logs 
               where DATE_FORMAT(created_at, '%Y/%m/%d') BETWEEN ? AND ? #{where_clause} "
    end
    @count = ClickLog.find_by_sql([sql_str] + params)
    @count[0]["cnt"].to_i
  end         
end
