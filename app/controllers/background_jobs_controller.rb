class BackgroundJobsController < ApplicationController
  before_filter :signed_in_user
  before_filter :must_super_agency
  layout false

  def create
    @jobs = BackgroundJob.where(:user_id => current_user.id,:type_view => 'download')
    render "background_jobs/new"
  end
  def upload
    @jobs = BackgroundJob.where(:user_id => current_user.id,:type_view => 'upload')
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
    @jobs = BackgroundJob.where(:user_id => current_user.id,:status => '1')
    render "background_jobs/inprogress"
  end
end
