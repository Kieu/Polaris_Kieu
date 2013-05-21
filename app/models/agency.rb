class Agency < ActiveRecord::Base
  attr_accessible :agency_name, :roman_name

  validates :agency_name, presence: true, uniqueness: {case_sensitive: false}
  validates :roman_name, presence: true, uniqueness: {case_sensitive: false}

  scope :order_by_roman_name, ->{order :roman_name}

end
