class Media < ActiveRecord::Base
  attr_accessible :media_category_id, :media_name, :del_flg

  has_many :accounts
end