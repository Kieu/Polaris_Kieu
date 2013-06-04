class BackgroundJobsController < ApplicationController
  before_filter :signed_in_user
  before_filter :must_super_agency
  layout false

  def create
    @jobs = BackgroundJob.all
    render "background_jobs/new"
  end
  def upload
    @jobs = BackgroundJob.all
    render "background_jobs/upload"
  end
  def index
    @jobs = BackgroundJob.all
    render "background_jobs/new"
  end
  def inprogress
    @jobs = BackgroundJob.all
    render "background_jobs/inprogress"
  end
end
