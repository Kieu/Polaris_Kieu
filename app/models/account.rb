class Account < ActiveRecord::Base
  VALID_NUMBER_REGEX = /^\d+$/
  VALID_ROMAN_NAME_REGEX = /^[A-Z_a-z][A-Za-z_0-9]*$/
  
  attr_accessible :cost, :create_user_id, :media_id, :promotion_id, :account_name, :roman_name,
                  :sync_account_id, :sync_account_pw, :sync_flg, :update_user_id
  
  validates :promotion_id, presence: true
  validates :promotion_id, format: {with: VALID_NUMBER_REGEX}, if: -> account { account.promotion_id.present?}
  validates :media_id, presence: true
  validates :media_id, format: {with: VALID_NUMBER_REGEX}, if: -> account { account.media_id.present?}
  validates :cost, presence: true, length: {maximum: 3}
  validates :cost, format: {with: VALID_NUMBER_REGEX}, if: -> account { account.cost.present?}
  validates :sync_flg, presence: true,  length: {maximum: 1} , if: -> account { account.sync_flg.present?}
  validates :sync_flg, format: {with: VALID_NUMBER_REGEX}, if: -> account { account.sync_flg.present?}
  validates :account_name, presence: true, length: {maximum: 255}, uniqueness: {case_sensitive: false}
  validates :roman_name, presence: true, length: {maximum: 255}, uniqueness: {case_sensitive: false}
  validates :roman_name, format: {with: VALID_ROMAN_NAME_REGEX}, if: -> account { account.roman_name.present?}
  validates :sync_account_id, presence: true, length: {maximum: 255}, uniqueness: {case_sensitive: false}, if: :check_sync
  validates :sync_account_pw, presence: true, length: {maximum: 255}, uniqueness: {case_sensitive: false}, if: :check_sync
  
  has_many :daily_summary_accounts
  has_many :daily_summary_acc_conversions
  belongs_to :promotion
  belongs_to :media

  private
  def check_sync
    sync_flg == 1 ? true : false
  end
end
