class Client < ActiveRecord::Base
  attr_accessible :client_name, :contract_flg, :contract_type, :del_flg, :department_name, :romaji_name, :tel, :create_usr_id, :update_usr_id

  has_many :client_users
  has_many :promotions
end
