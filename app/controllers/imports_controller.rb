class ImportsController < ApplicationController
  def create
    @import = Import.new(params[:import])
    @import.change_file_name(current_user.id) unless params[:import].nil?
    if @import.save
      background_job = BackgroundJob.new
      background_job.user_id = current_user.id
      background_job.filename = @import.csv_file_name
      background_job.type_view = Settings.type_view.UPLOAD
      background_job.status = Settings.job_status.PROCESSING
      background_job.controller = params[:controller]
      background_job.save!
      job_id = ImportUrlData.create(file: @import.csv.url,
        bgj_id: background_job.id, type: params[:type])
      background_job.job_id = job_id
      background_job.save!
      flash[:error] = "upload success"
      redirect_to url_settings_path
    else
      flash[:error] = "Upload fail"
      render "url_settings/index"
    end
  end
end
