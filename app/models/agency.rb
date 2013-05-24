class Agency < ActiveRecord::Base
  attr_accessible :agency_name, :roman_name

  has_many :promotions

  validates :agency_name, presence: true, uniqueness: {case_sensitive: false},
    length: {maximum: 255}
  validates :roman_name, presence: true, uniqueness: {case_sensitive: false},
    length: {maximum: 255}
  
  scope :order_by_roman_name, ->{order :roman_name}
end
