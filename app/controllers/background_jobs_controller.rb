class BackgroundJobsController < ApplicationController
  before_filter :signed_in_user
  layout false

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
