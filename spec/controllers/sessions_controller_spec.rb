require 'spec_helper'

describe SessionsController do

  describe "GET new" do
    let(:action) {get :new}
    it "returns http success" do
      action
      response.should be_success
    end
  end
  
  describe "POST create" do
    let :user do
      FactoryGirl.create(:user)
    end
   
    describe "with valid login info" do
      let(:action) do
        post :create, session: {email: user.email, password: user.password}
      end
      
      it "makes user login" do
        action
        session[:user_id].should eq user.id
        response.should redirect_to clients_path
      end
      
      describe "when user is blocked less than 5 minutes" do
        before do
          BlockLoginUser.create(user_id: user.id, login_fail_num: 3,
            block_at_time: 3.minutes.ago)
        end
        it "not makes user login" do
          action
          session[:user_id].should be_nil
          response.should render_template :new
        end
      end
      
      describe "when user is blocked greater than 5 minutes" do
        before do
          BlockLoginUser.create(user_id: user.id, login_fail_num: 3,
            block_at_time: 6.minutes.ago)
        end
        it "not makes user login" do
          action
          session[:user_id].should eq user.id
          response.should redirect_to clients_path
        end
      end
    end
    
    describe "with invalid login info" do
      before do
        BlockLoginUser.create(user_id: user.id, login_fail_num: 0)
      end
      let(:action) do
        post :create, session: {email: user.email, password: "something"}
      end
      it "not makes user login" do
        action
        session[:user_id].should be_nil
        response.should render_template :new
      end
    end
  end

  describe "DELETE 'destroy'" do
    let(:user) {FactoryGirl.create :user}
    let(:action) {delete :destroy}
    before do
      session[:user_id] = user.id
      action
    end
    it "destroy current session" do
      session[:user_id].should be_nil
    end
    it "redirects to root" do
      response.should redirect_to root_path
    end
  end
end
