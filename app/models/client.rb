class Client < ActiveRecord::Base
  VALID_PHONE_NUMBER_REGEX = /^\+{0,1}\d+[\d]+$/

  attr_accessible :client_name, :roman_name, :tel, :department_name,
    :contract_flg, :contract_type, :person_charge, :person_sale,
    :create_user_id, :update_user_id, :del_flg

  has_many :client_users
  has_many :promotions

  validates :client_name, presence: true, uniqueness: {case_sensitive: false}
  validates :roman_name, presence: true, uniqueness: {case_sensitive: false}
  validates :tel, presence: true, length: {maximum: 15},
    format: {with: VALID_PHONE_NUMBER_REGEX}, uniqueness: true
  validates :contract_flg, presence: true
  validates :contract_type, presence: true
  validates :person_charge, presence: true
  validates :person_sale, presence: true
end
