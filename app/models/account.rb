class Account < ActiveRecord::Base
  VALID_NUMBER_REGEX = /^\d+$/
  
  attr_accessible :cost, :create_user_id, :media_id, :promotion_id, :account_name, :roman_name,
                  :sync_account_id, :sync_account_pw, :sync_flg, :update_user_id
  
  validates :promotion_id, presence: true,
            format: {with: VALID_NUMBER_REGEX}
  validates :media_id, presence: true,
            format: {with: VALID_NUMBER_REGEX}
  validates :cost, presence: true,
            format: {with: VALID_NUMBER_REGEX}, length: {maximum: 3}
  validates :sync_flg, presence: true,
            format: {with: VALID_NUMBER_REGEX}, length: {maximum: 1}
  validates :account_name, presence: true, length: {maximum: 255}, uniqueness: {case_sensitive: false}
  validates :roman_name, presence: true, length: {maximum: 255}, uniqueness: {case_sensitive: false}              
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
