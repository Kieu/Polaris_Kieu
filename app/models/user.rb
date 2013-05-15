class User < ActiveRecord::Base
  has_secure_password

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  attr_accessible :email, :fullname, :language, :last_login, :password,
    :password_flg, :role_id, :status, :username, :create_usr_id, :update_usr_id

  belongs_to :role
  has_one :block_login_user
  has_many :client_users

  validates :username, presence: true, uniqueness: {case_sensitive: true}
  validates :email, presence:   true,
                    format:     {with: VALID_EMAIL_REGEX},
                    uniqueness: {case_sensitive: false}

  before_save {|user| user.email = email.downcase}
  
  def can_login?
    if self.block_login_user && self.block_login_user.login_fail_num >=
      Settings.login.login_block_number
      if self.block_login_user.block_at_time > 5.minutes.ago
        return false
      else
        return self.remove_block_login
      end
    else
      return true
    end
  end
  
  def update_login_fail
    block = self.block_login_user
    if block
      if block.login_fail_num < Settings.login.login_block_number
        block.login_fail_num += 1
        block.block_at_time = Time.now if block.login_fail_num >=
          Settings.login.login_block_number
        block.save!
      end
    else
      BlockLoginUser.create(user_id: self.id, login_fail_num: 1)
    end
  end
  
  def remove_block_login
    self.block_login_user.login_fail_num = 0
    self.block_login_user.block_at_time = nil
    self.block_login_user.save
  end
end
