class AccountsController < ApplicationController
  before_filter :signed_in_user
  before_filter :must_super_agency
  def new
    @account = Account.new
    @promotion_id= params[:promotion_id]
  end
  
  def create
    @account = Account.new(params[:account])
    @promotion_id= params[:account][:promotion_id]
    @account.create_user_id = current_user.id
    if @account.save
      flash[:success] = "Client was successfully created"
      redirect_to new_account_path
    else
      render :new
    end
  end
end
