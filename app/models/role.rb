class Role < ActiveRecord::Base
  attr_accessible :active_flg, :role_name, :create_usr_id, :update_usr_id

  has_many :users
end
