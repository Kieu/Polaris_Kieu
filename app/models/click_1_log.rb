class Click_1_Log < ActiveRecord::Base
  establish_connection :log_db_development
  attr_accessible :access_track_server, :account_id, :group_id, :unit_id,
                  :campaign_id, :click_utime, :click_url, :click_ymd, :creative_id,
                  :device_category, :mark, :media_category_id, :media_id, :media_session_id, :mpv,
                  :redirect_infomation_id, :redirect_url, :redirect_url_id, :referrer, :remote_ip,
                  :request_uri, :session_id, :user_agent, :verify, :error_code, :state
end
