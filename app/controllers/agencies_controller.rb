class AgenciesController < ApplicationController
  before_filter :signed_in_user
  before_filter :must_super
  before_filter :get_agency, only: [:edit, :update]

  def index
  end

  def get_agencies_list
    start = ((params[:page].to_i - 1) * params[:rp].to_i)
    params[:rp] = ["10", "20", "30", "40", "50"]
      .include?(params[:rp]) ? params[:pr] : "10"
    rows = get_rows(Agency.limit(params[:rp]).offset(start))
    render json: {page: params[:page], total: Agency.count, rows: rows}
  end
  
  def edit
  end

  def update
    @errors = Array.new
    @agency.update_user_id = current_user.id
    if @agency.update_attributes(params[:agency])
      flash[:error] = "Agency info updated"
      redirect_to agencies_path
    else
      @errors << @agency.errors.full_messages
      render :edit
    end
  end

  private
  def get_agency
    @agency = Agency.find(params[:id])
  end
  def get_rows agencies
    rows = Array.new
    agencies.each do |agency|
      link = "<a href='agencies/#{agency.id}/edit'>Edit</a>"
      rows << {id: agency.id, cell: {link: link,agency_name: agency.agency_name,
                roman_name: agency.roman_name}}
    end
    rows
  end
end
