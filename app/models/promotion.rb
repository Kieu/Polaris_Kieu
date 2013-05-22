class Promotion < ActiveRecord::Base
  attr_accessible :agency_id, :client_id, :create_user_id, :del_flg, :promotion_category_id, :promotion_name, :update_user_id

  belongs_to :client

  searchable do
    text :promotion_name, :stored => true
    integer :client_id
    string :status
    time :created_at
  end
end
