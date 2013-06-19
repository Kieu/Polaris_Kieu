class ImportsController < ApplicationController
  def create
    @import = Import.new(params[:import])
    @import.change_file_name(current_user.id) unless params[:import].nil?
    if @import.save
      background_job = BackgroundJob.new
      background_job.user_id = current_user.id
      background_job.type_view = Settings.type_view.UPLOAD
      background_job.status = Settings.job_status.PROCESSING
      background_job.save!
      if params[:type] == 'insert'
        job_id = ImportUrlData.create(file: @import.csv.url,
                 bgj_id: background_job.id, type: params[:type], user_id: current_user.id,
                 promotion_id: params[:promotion_id], account_id: params[:account_id], 
                 media_id: params[:media_id], client_id: params[:client_id], 
                 media_category_id: params[:media_category_id])
      else
        job_id = UpdateUrlData.create(file: @import.csv.url,
                 bgj_id: background_job.id, type: params[:type], user_id: current_user.id,
                 promotion_id: params[:promotion_id], account_id: params[:account_id], 
                 media_id: params[:media_id], client_id: params[:client_id], 
                 media_category_id: params[:media_category_id])
      end
      
      background_job.job_id = job_id
      background_job.save!
      flash[:error] = t("url.flash_messages.success")
      redirect_to url_settings_path(promotion_id: params[:promotion_id], account_id: params[:account_id])
    else
      flash[:error] = "Upload false"
      redirect_to url_settings_path(promotion_id: params[:promotion_id], account_id: params[:account_id])
    end
  end
end
