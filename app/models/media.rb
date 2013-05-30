class Media < ActiveRecord::Base
  attr_accessible :id, :media_category_id, :media_name, :del_flg
end
