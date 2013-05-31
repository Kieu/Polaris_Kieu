class ExtPromotionReport < ActiveRecord::Base
  attr_accessible :account_id, :click, :cost, :imp, :media_category_id, :media_id, :promotion_id, :report_date
end
