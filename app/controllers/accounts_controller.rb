class AccountsController < ApplicationController
  before_filter :signed_in_user
  before_filter :must_super_agency
  def new
    @account = Account.new
    @promotion_id = params[:promotion_id]
    @promotion = Promotion.find_by_id(@promotion_id)
  end
  
  def edit
    @account = Account.find(params[:id])
    @promotion_id = params[:promotion_id]
    @promotion = Promotion.find_by_id(@promotion_id)
  end
  def update
    @account = Account.find(params[:id])
    @promotion_id = params[:promotion_id]
    @promotion = Promotion.find_by_id(@promotion_id)
    @account.create_user_id = current_user.id
    if @account.update_attributes(params[:account])
      flash[:success] = I18n.t("account.flash_messages.success")
      redirect_to promotions_path
    else
      render :edit
    end
  end
  def create
    @account = Account.new(params[:account])
    @promotion_id = params[:promotion_id]
    #get promotion by id
    @promotion = Promotion.find_by_id(@promotion_id)
    @account.create_user_id = current_user.id
    if @account.save
      flash[:success] = "Client was successfully created"
      redirect_to promotions_path
    else
      render "new", promotion_id: @promotion_id
    end
  end
end
