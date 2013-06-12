class BackgroundJobsController < ApplicationController
  before_filter :signed_in_user
  layout false
  # Stream a file that has already been generated and stored on disk
  def download_file
    job = BackgroundJob.find(params[:id])
    binding.pry
    send_data("#{RAILS_ROOT}/Settings.#{job.controller}/#{job.filename}", :filename => "#{job.filename}", :type => "text/csv")
  end
  def download
    @jobs = BackgroundJob.where(:user_id => current_user.id,:type_view => 'download',:status =>'1')
    render "background_jobs/new"
  end
  def upload
    @jobs = BackgroundJob.where(:user_id => current_user.id,:type_view => 'upload',:status =>'1')
    render "background_jobs/upload"
  end
  def index
    @jobs = BackgroundJob.all
    render "background_jobs/new"
  end
  def notification
    @jobs = BackgroundJob.where(:user_id => current_user.id,:status => '0').size
    render :text => @jobs
  end
  def inprogress
    @jobs = BackgroundJob.where(:user_id => current_user.id,:status => '0')
    render "background_jobs/inprogress"
  end
  def kill_job
    @job = BackgroundJob.find(params[:id])
    Resque::Plugins::Status::Hash.kill(@job.job_id)
  end
end
