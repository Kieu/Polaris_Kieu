class Client < ActiveRecord::Base
  VALID_PHONE_NUMBER_REGEX = /^\+{0,1}\d+[\d]+$/

  attr_accessible :client_name, :roman_name, :tel, :department_name,
    :contract_flg, :contract_type, :person_charge, :person_sale,
    :create_user_id, :update_user_id, :del_flg

  has_many :client_users
  has_many :promotions

  validates :client_name, presence: true, uniqueness: {case_sensitive: false},
    length: {maximum: 255}
  validates :roman_name, presence: true, uniqueness: {case_sensitive: false},
    length: {maximum: 255}
  validates :tel, presence: true, length: {maximum: 15},
    format: {with: VALID_PHONE_NUMBER_REGEX}, uniqueness: true
  validates :contract_flg, presence: true
  validates :contract_type, presence: true
  validates :person_charge, presence: true, length: {maximum: 255}
  validates :person_sale, presence: true, length: {maximum: 255}
  
  def update_client_users params
    params[:users_id].each do |user_id|
      return false unless User.find_by_id(user_id) 
      if client_user = self.client_users.find_by_user_id(user_id)
      else
         client_user = self.client_users.build(user_id: user_id)
      end
      del_flg = params["del_user_" + user_id] == "on" ? "1" : "0"
      client_user.del_flg = del_flg
      if client_user.valid?
        client_user.save!
      else
        return false
      end
    end
  end
end