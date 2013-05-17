class ClientUser < ActiveRecord::Base
  attr_accessible :client_id, :user_id, :del_flg

  belongs_to :client
  belongs_to :user
end
