class Promotion < ActiveRecord::Base
  attr_accessible :agency_id, :client_id, :create_user_id, :del_flg, :promotion_category_id, :promotion_name, :update_user_id
  belongs_to :client
  scope :order_by_promotion_name, ->{order :promotion_name}
end
