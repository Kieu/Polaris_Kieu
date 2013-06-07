class UrlSettingsController < ApplicationController
  before_filter :set_cookies
	def index
		#mpv = make_mpv media_category_id, promotion_id, account_id, redirect_infomation_id
    @promotion_id = 1
    @account_id = 1
    @media_id = 1
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
      edit_button = 'edit'
      copy_button = "button"
      delete_check = "delete_check"

      rows << { id: url['redirect_url_id'], cell: {edit_button: edit_button, ad_id: url['ad_id'], campaign_name: url['campaign_name'],
               group_name: url['group_name'], ad_name: url['ad_name'], url: url['url'], copy: copy_button,
               delete_check: delete_check}}
    end

    rows
  end

  private
  def set_cookies
    time = Time.new
    cookies[:s]="#{time.year}/#{time.month}/01" if !cookies[:s] 
    cookies[:e]="#{time.year}/#{time.month}/#{time.day}" if !cookies[:e]
    cookies[:ser] = "1" if !cookies[:ser]
  end
end
