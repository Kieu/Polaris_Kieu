class RedirectInfomation < ActiveRecord::Base
  self.table_name = "redirect_informations"
  attr_accessible :mpv, :client_id, :promotion_id, :media_category_id, :media_id, :account_id, :campaign_id, :group_id,
                                 :unit_id, :creative_id, :click_unit, :del_flg
end
