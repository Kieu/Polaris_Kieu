class Promotion < ActiveRecord::Base
  attr_accessible :promotion_category_id, :promotion_name, :roman_name, :tracking_period,
    :client_id, :agency_id

  belongs_to :client
  belongs_to :agency

  validates :promotion_name, presence: true, uniqueness: {case_sensitive: false}
  validates :roman_name, presence: true, uniqueness: {case_sensitive: false}
  validates :promotion_category_id, presence: true
  validates :tracking_period, presence: true, inclusion: {in: 1..90}
  validates :client_id, presence: true
  validates :agency_id, presence: true

  scope :order_by_promotion_name, ->{order :promotion_name}
end
