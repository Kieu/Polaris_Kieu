class Promotion < ActiveRecord::Base
  attr_accessible :promotion_category_id, :promotion_name, :roman_name, :tracking_period,
    :client_id, :agency_id, :del_flg, :update_user_id

  belongs_to :client
  belongs_to :agency
  has_many :conversions
  has_many :accounts

  validates :promotion_name, presence: true, uniqueness: {scope: :client_id}
  validates :roman_name, presence: true, uniqueness: {scope: :client_id}
  validates :promotion_category_id, presence: true
  validates :tracking_period, presence: true, inclusion: {in: 1..90}
  validates :client_id, presence: true
  validates :agency_id, presence: true

  scope :order_by_promotion_name, ->{order :promotion_name}
  scope :get_by_client, lambda {|client_id| where(client_id: client_id)}

  def delete
    self.update_attribute(:del_flg, Settings.promotion.deleted)
  end

  def deleted?
    self.del_flg == Settings.promotion.deleted
  end
end
