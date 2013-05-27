class AgenciesController < ApplicationController
  before_filter :signed_in_user
  before_filter :must_super
  before_filter :get_agency, only: [:edit, :update]

  def index
  end

  def get_agencies_list
    rows = get_rows(Agency.order_by_roman_name.page(params[:page]).per(params[:rp]))
    render json: {page: params[:page], total: Agency.count, rows: rows}
  end
  
  def edit
  end

  def update
    @agency.update_user_id = current_user.id
    if @agency.update_attributes(params[:agency])
      flash[:error] = "Agency info updated"
      redirect_to agencies_path
    else
      render :edit
    end
  end

  def new
    @agency = Agency.new
  end

  def create
    @agency = Agency.new(params[:agency])
    @agency.create_user_id = current_user.id
    if @agency.save
      flash[:error] = 'Agency is created successful'
      redirect_to new_agency_path
    else
      render :new
    end
  end

  private
  def get_agency
    @agency = Agency.find(params[:id])
  end

  def get_rows agencies
    rows = Array.new
    agencies.each do |agency|
      link = view_context.link_to("Edit", edit_agency_path(agency))
      rows << {id: agency.id, cell: {link: link,agency_name: agency.agency_name,
                roman_name: agency.roman_name}}
    end
    rows
  end
end
