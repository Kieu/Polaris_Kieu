class BackgroundJob < ActiveRecord::Base
  attr_accessible :user_id, :filename, :type_view, :status, :controller, :job_id
end
