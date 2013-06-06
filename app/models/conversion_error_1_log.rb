class Conversion_error_1_Log < ActiveRecord::Base
  establish_connection :log_db_development

  attr_accessible :media_category_id, :media_id, :account_id, 
  :campaign_id, :group_id, :unit_id, :conversion_id, :redirect_infomation_id, 
  :mpv, :redirect_url_id, :redirect_url, :creative_id, :session_id, :verify, :suid, :request_uri,
  :request_url, :media_session_id, :device_category, :user_agent, :referrer, 
  :click_referrer, :conversion_utime, :conversion_ymd, :click_time, :remote_ip, :mark, :conversion_category, :conversion_type, :repeat_flg, 
  :sales, :profit, :volume, :others,
  :approval_status, :send_url, :send_utime, :access_track_server
end