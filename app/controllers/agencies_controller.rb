class AgenciesController < ApplicationController
  before_filter :signed_in_user
  before_filter :must_super
  before_filter :get_agency, only: [:edit, :update]

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

  def new
    @agency = Agency.new
  end

  def create
    @errors = Array.new
    @agency = Agency.new(params[:agency], create_user_id: current_user.id)
    if @agency.save
      redirect_to agencies_path
    else
      @errors << @agency.errors.full_messages
      render :new
      return
    end
  end

  private
  def get_agency
    @agency = Agency.find(params[:id])
  end

end
