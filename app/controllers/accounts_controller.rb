class AccountsController < ApplicationController
  before_filter :signed_in_user
  before_filter :must_super_agency
  before_filter :must_right_object, only: [:edit, :update]
  def new
    @account = Account.new
    @promotion_id = params[:promotion_id]
    @promotion = Promotion.find_by_id(@promotion_id)
    @medias = Media.active.where(media_category_id: 1)
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
    
    @account.attributes = params[:account]
    @account.update_user_id = current_user.id
    
    ActiveRecord::Base.transaction do
      if @account.save
        @margin = MarginManagement.new
        time = Time.new
        @margin.report_ymd = "#{time.year}#{time.month}#{time.day}"
        @margin.account_id = @account.id
        @margin.margin_rate = @account.cost
        @margin.create_user_id = current_user.id
        @margin.update_user_id = current_user.id
        @margin.create_time = time
        @margin.update_time = time
        if !@margin.save        
          flash[:error] = I18n.t("account.flash_messages.success_error")
          raise ActiveRecord::Rollback
        end
      end
    end
       
    if flash[:error]
      render :edit
    else
      flash[:error] = I18n.t("account.flash_messages.success")
      redirect_to promotions_path(promotion_id: @promotion_id, client_id: @promotion.client.id)
    end
  end
  def create
    
    @account = Account.new(params[:account])
    
    @medias = Media.active.where(media_category_id: @account.media_category_id)
    @promotion_id = params[:promotion_id]
    #get promotion by id
    @promotion = Promotion.find_by_id(@promotion_id)
    @account.create_user_id = current_user.id
    if !@account.sync_flg
      @account.sync_account_id = ""
      @account.sync_account_pw = ""
    end
    if @account.valid?
      ActiveRecord::Base.transaction do
        if @account.save
          @margin = MarginManagement.new
          time = Time.new
          @margin.report_ymd = "#{time.year}#{time.month}#{time.day}"
          @margin.account_id = @account.id
          @margin.margin_rate = @account.cost
          @margin.create_user_id = current_user.id
          @margin.create_time = time
          @margin.update_time = time
          if !@margin.save        
            flash[:error] = I18n.t("account.flash_messages.success_error")
            raise ActiveRecord::Rollback
          end
        end
      end
      if flash[:error]
        #render :new
        render "new", promotion_id: @promotion_id
      else
        flash[:error] = I18n.t("account.flash_messages.success")
        redirect_to promotions_path(promotion_id: @promotion_id, client_id: @promotion.client.id)
      end
    else
      @account.sync_flg = 1
      render "new", promotion_id: @promotion_id
    end
  end
  
  def change_medias_list
    render json: Media.active.where(media_category_id: params[:cid])
  end
  
  private
  def must_right_object
    @account = Account.find(params[:id])
    if current_user.agency? && !@account.promotion.client.client_users.find_by_user_id(current_user.id)
      redirect_to promotions_path(promotion_id: params[:promotion_id], client_id: @account.promotion.client.id)
    end
  end
end
