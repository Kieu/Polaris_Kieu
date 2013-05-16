require 'spec_helper'

describe User do
  let(:user){FactoryGirl.create(:user)}
  it { should respond_to(:username) }
  it { should respond_to(:roman_name) }
  it { should respond_to(:email) }
  it { should respond_to(:role_id) }
  it { should respond_to(:company) }
  it { should respond_to(:password_flg) }
    
  describe "when username is not present" do
    before { user.username = " " }
    it { should_not be_valid }
  end
    
  describe "when roman name is not present" do
    before { user.roman_name = " " }
    it { should_not be_valid }
  end
    
  describe "when email is not present" do
    before { user.email = " " }
    it { should_not be_valid }
  end
    
  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
        foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        user.email = invalid_address
        user.should_not be_valid
      end      
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        user.email = valid_address
        user.should be_valid
      end      
    end
  end
    
  describe "when email address is already taken" do
    before do
      user_with_same_email = user.dup
      user_with_same_email.email = user.email.upcase
      user_with_same_email.save
    end
  
    it { should_not be_valid }
  end
  
  describe "#can_login?" do
    context "when user can login" do
      it "should return true value" do
        user.can_login?.should eq(true)
      end
    end
    context "when user has been blocked" do
      context "within 5 minutes" do
        before do
          block = BlockLoginUser.new(login_fail_num: 3,
            block_at_time: Time.now)
          user.block_login_user = block
        end
        it "should return false value" do
          user.can_login?.should eq(false)
        end
      end
      context "not within 5 minutes" do
        before do
          block = BlockLoginUser.create(user_id: user.id, login_fail_num: 3,
            block_at_time: 6.minutes.ago)
          user.block_login_user = block
        end
        it "should remove login_fail_num to 0 value" do
          user.can_login?
          user.block_login_user.login_fail_num.should eq(0)
          user.block_login_user.block_at_time.should eq(nil)
        end
      end
    end
  end
end