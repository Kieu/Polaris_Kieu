class ConversionError1Logs < ActiveRecord::Base
  attr_accessible :access_time, :access_vmd, :account_id, 
  :ad_group_id, :ad_id, :campaign_id, :click_referrer, :click_time, 
  :conversion_category, :conversion_id, :conversion_type, :creative_id, 
  :device_category, :mark, :media_category_id, :media_id, :media_session_id, 
  :mpv, :redirect_infomation_id, :redirect_url, :redirect_url_id, :referrer, 
  :remote_ip, :sales, :reqest_url, :session_id, :suid, :user_agent, :verify
end
