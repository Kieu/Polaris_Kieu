require 'csv'
require 'time'

class UrlSettingsController < ApplicationController
  before_filter :set_cookies
  before_filter :signed_in_user
  before_filter :must_super_agency

	def index
    @promotion_id = params[:promotion_id]
    @account_id = params[:account_id]
    @promotion = Promotion.where(id: @promotion_id).select('client_id, promotion_name')
    @promotion_name = @promotion.first['promotion_name']
    @client_id = @promotion.first['client_id']
    @client = Client.where(id: @client_id).select('client_name, create_user_id')
    @client_name = @client.first['client_name']
    create_user_id = @client.first['create_user_id']

    if (current_user.id != create_user_id) && (current_user.role.id == Settings.role.AGENCY)
      render file: 'public/404.html', status: :not_found
      return
    end

    @account = Account.where(id: @account_id).select('media_id, account_name')
    @account_name = @account.first['account_name']
    @media_id = @account.first['media_id']
    @media_result = Media.where(id: @media_id).select('media_name, media_category_id')
    @media_name = @media_result.first['media_name']
    @media_category_id = @media_result.first['media_category_id']
	end
  
  def get_urls_list
    start_date = params[:start_date]
    end_date = params[:end_date]
    if  !start_date || !end_date
      start_date = Date.yesterday.at_beginning_of_month.strftime("%Y/%m/%d")
      end_date = Date.yesterday.strftime("%Y/%m/%d")
    end
    
    url_data = Array.new
    url_data, total_row = RedirectUrl.get_url_data(params[:promotion_id], params[:account_id], params[:media_id],
                                 params[:page], params[:rp], start_date, end_date)
    rows = get_rows url_data, params[:promotion_id], params[:client_id]
    count = total_row[0]['totalCount']

    render json: {page: params[:page], total: count, rows: rows}
  end

  def download_template
    if cookies[:locale] == 'ja'
      path_to_file = "#{Rails.root}/" + Settings.URL_TEMPLATE_FILE.JP
    else
      path_to_file = "#{Rails.root}/" + Settings.URL_TEMPLATE_FILE.EN
    end
    
    account_name = Account.where(id: params[:account_id]).select('roman_name').first['roman_name']
    file_name = account_name + "_URL_" + Time.now.strftime("%Y%m%d") + Settings.file_type.CSV
    send_file(path_to_file, filename: file_name, type: "text/csv; charset=utf-8")
  end

  def get_rows url_data, promotion_id, client_id
    rows = Array.new
    url_data.each do |url|
      redirect_url_id = url['redirect_url_id']
      edit_button = '<a href="#"> <img src="/assets/img_edit.png" alt="Edit URL"></a>'
      copy_button = '<a href="#"><img src="/assets/btn_copy2.gif" /></a>'
      delete_check = '<input type="checkbox" name="del_url_#{redirect_url_id}" id="#{redirect_url_id}" />'
      image = url['creative']
      comment = url['comment']
      submit_url = "<div align='left' id='url_#{url['redirect_url_id']}'>" + Settings.DOMAIN_SUBMIT_URL + "mpv=#{url['mpv']}" + "&cid=#{client_id}&pid=#{promotion_id} </div>"
      submit_url += "<div align='right'><a href='#' onClick='ClipBoard(url_#{url['redirect_url_id']});'><img src='/assets/btn_copy2.gif' /></a></div>"
      if url['creative_type'] == '1'
        creative = '<img src=' + "/assets/creative/#{image}" + '  />'
      else
        creative = url['creative_text']
      end
      
      rows << { id: url['redirect_url_id'], cell: {edit_button: edit_button, ad_id: url['ad_id'], campaign_name: url['campaign_name'],
               group_name: url['group_name'], ad_name: url['ad_name'], creative: creative, url: submit_url,
               delete_check: delete_check, note: comment, last_modified: url['last_modified'] }}
    end

    rows
  end

  def download_csv
    start_date = params[:start_date]
    end_date = params[:end_date]
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
    cookies[:url_setting] = "11111110011" if !cookies[:url_setting]
  end
end
