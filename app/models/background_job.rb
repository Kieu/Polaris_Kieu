class BackgroundJob < ActiveRecord::Base
  attr_accessible :user_id, :filename, :type_view, :status, :create_at, :updated_at
end
