class ClientUser < ActiveRecord::Base
  attr_accessible :client_id, :user_id, :del_flg
  
  validates :client_id, presence: true
  validates :user_id, presence: true

  belongs_to :client
  belongs_to :user
end