require 'csv'
require 'time'

class UrlSettingsController < ApplicationController
  before_filter :set_cookies
  before_filter :signed_in_user
	def index
		#mpv = make_mpv media_category_id, promotion_id, account_id, redirect_infomation_id

    @promotion_id = 1
    @account_id = 1
    @promotion = Promotion.where(id: @promotion_id).select('client_id, promotion_name')
    @promotion_name = @promotion.first['promotion_name']
    @client_id = @promotion.first['client_id']
    @client_name = Client.where(id: @client_id).select('client_name').first['client_name']
    @account = Account.where(id: @account_id).select('media_id, account_name')
    @account_name = @account.first['account_name']
    @media_id = @account.first['media_id']
    @media_result = Media.where(id: @media_id).select('media_name, media_category_id')
    @media_name = @media_result.first['media_name']
    @media_category_id = @media_result.first['media_category_id']
	end
  
  def get_urls_list
    start_date = cookies[:s]
    end_date = cookies[:e]
    url_data = Array.new
    url_data = RedirectUrl.get_url_data(params[:promotion_id], params[:account_id], params[:media_id],
                                 params[:page], params[:rp], start_date, end_date)
    rows = get_rows(url_data)
    count = url_data.count

    render json: {page: params[:page], total: count, rows: rows}
  end

  def get_rows url_data
    rows = Array.new
    url_data.each do |url|
      redirect_url_id = url['redirect_url_id']
      edit_button = '<a href="#"> <img src="/assets/img_edit.png" alt="Edit URL"></a>'
      copy_button = '<a href="#"><img src="/assets/btn_copy2.gif" /></a>'
      delete_check = '<input type="checkbox" name="del_url_#{redirect_url_id}" id="#{redirect_url_id}" />'
      image = url['creative']
      if url['creative_type'] == '1'
        creative = '<img src=' + "/assets/creative/#{image}" + '  />'
      else
        creative = url['creative_text']
      end
      
      rows << { id: url['redirect_url_id'], cell: {edit_button: edit_button, ad_id: url['ad_id'], campaign_name: url['campaign_name'],
               group_name: url['group_name'], ad_name: url['ad_name'], creative: creative, url: url['url'], copy: copy_button,
               delete_check: delete_check, last_modified: url['last_modified'] }}
    end

    rows
  end

  def download_csv
    start_date = cookies[:s]
    end_date = cookies[:e]
    user_id = current_user.id
    promotion_id = params[:promotion_id]
    account_id = params[:account_id]
    media_id = params[:media_id]
    
    background_job = BackgroundJob.create
    job_id = ExportUrlData.create(start_date: start_date, end_date: end_date,
      user_id: user_id, promotion_id: promotion_id, account_id: account_id,
      media_id: media_id, bgj_id: background_job.id)
    background_job.job_id = job_id
    background_job.save!
    
    render text: "processing"
  end
  private
  def set_cookies
    time = Time.new
    cookies[:url_setting_start_date] = Date.yesterday.at_beginning_of_month.strftime("%Y/%m/%d") if !cookies[:url_setting_start_date] 
    cookies[:url_setting_end_date] = Date.yesterday.strftime("%Y/%m/%d") if !cookies[:url_setting_end_date]
    cookies[:url_setting] = "1111111111" if !cookies[:url_setting]
  end
end
