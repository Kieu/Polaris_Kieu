class BackgroundJobsController < ApplicationController
  before_filter :signed_in_user
  layout false
  # Stream a file that has already been generated and stored on disk
  def download_file
    job = BackgroundJob.find(params[:id])
    if current_user.id==job.user_id
      controller_path = job.controller.to_s
      path = Rails.root + '/public/file.csv'
      send_data(path, :filename => "#{job.filename}", :type => "text/csv")
    end
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
    job = BackgroundJob.find(params[:id])
    if current_user.id==job.user_id
      #send signed for job
     Resque::Plugins::Status::Hash.kill(job.job_id)
     render :text => 'kill job'
    end
  end
end
