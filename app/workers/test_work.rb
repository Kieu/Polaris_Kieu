require 'csv'

# export promotion data table from promotion screen to csv file
class TestWork
  @queue = :test_work

  def self.perform
    
    ActiveRecord::Base.transaction do
      (1..10).each do |num|
        background_job = BackgroundJob.new
        background_job.user_id = 1
        background_job.filename = "#{num}_test_work.txt"
        background_job.type_view = Settings.type_view.UPLOAD
        background_job.status = Settings.job_status.PROCESSING
        background_job.controller = "test_controll"
        background_job.save!


        binding.pry
        exit
      end
    end
  end
end
