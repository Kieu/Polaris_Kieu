class Conversion_organic_1_Log < ActiveRecord::Base
  attr_accessible :conversion_id, :redirect_infomation_id, 
  :redirect_url, :verify, :suid, :request_url, :media_session_id, :device_category, 
  :user_agent, :referrer, :remote_ip, :conversion_category, :conversion_type, :repeat_flg, 
  :sales, :profit, :volume, :others, :send_url, :send_utime
end
