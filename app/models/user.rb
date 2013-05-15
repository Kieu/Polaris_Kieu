class User < ActiveRecord::Base
  has_secure_password

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]{2,}+\z/i

  attr_accessible :username, :roman_name, :email, :company, :role_id,
    :password_flg, :language

  belongs_to :role
  has_many :client_users

  validates :username, presence: true
  validates :roman_name, presence: true
  validates :email, presence: true, uniqueness: {case_sensitive: false},
    format: {with: VALID_EMAIL_REGEX}, length: {maximum: 100}
  validates :company, presence: true
  validates :role_id, presence: true
  validates :password_flg, presence: true

  before_save {|user| user.email = email.downcase}
end
