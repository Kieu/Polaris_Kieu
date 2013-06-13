class Account < ActiveRecord::Base
  VALID_NUMBER_REGEX = /^\d+$/
  VALID_ROMAN_NAME_REGEX = /^[A-Z_\-a-z][A-Za-z_\-0-9]*$/
  
  attr_accessible :cost, :create_user_id, :media_id, :promotion_id, :account_name, :roman_name,
                  :sync_account_id, :sync_account_pw, :sync_flg, :update_user_id, :media_category_id
  
  validates :promotion_id, presence: true
  validates :promotion_id, format: {with: VALID_NUMBER_REGEX}, if: -> account { account.promotion_id.present?}
  validates :media_id, presence: true
  validates :media_id, format: {with: VALID_NUMBER_REGEX}, if: -> account { account.media_id.present?}
  validates :cost, presence: true, length: {maximum: 255}
  validates :cost, format: {with: VALID_NUMBER_REGEX}, if: -> account { account.cost.present?}
  validates :sync_flg, presence: true,  length: {maximum: 1} , if: -> account { account.sync_flg.present?}
  validates :sync_flg, format: {with: VALID_NUMBER_REGEX}, if: -> account { account.sync_flg.present?}
  validates :account_name, presence: true, length: {maximum: 255}, uniqueness: {case_sensitive: false, scope: :promotion_id}
  validates :roman_name, presence: true, length: {maximum: 255}, uniqueness: {case_sensitive: false, scope: :promotion_id}
  validates :roman_name, format: {with: VALID_ROMAN_NAME_REGEX}, if: -> account { account.roman_name.present?}
  validates :sync_account_id, presence: true, length: {maximum: 255}, if: :check_sync
  validates :sync_account_pw, presence: true, length: {maximum: 255}, if: :check_sync
  
  has_many :daily_summary_accounts
  has_many :daily_summary_acc_conversions
  belongs_to :promotion
  belongs_to :media
  
  def self.get_account_list promotion_id, media_list
    results = Hash.new
    accounts_list = Account.where(promotion_id: promotion_id)
    Settings.media_category.each do |category|
      media_list[category[1]+"_media"].each do |media|
        results["media"+media.id.to_s+"_account"] = Array.new
      end
    end
    
    accounts_list.each do |account|
      results["media"+account.media_id.to_s+"_account"] << account
    end
    results
  end

  private
  def check_sync
    sync_flg == 1 ? true : false
  end
end
