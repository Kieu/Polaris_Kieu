require 'spec_helper'

describe UsersController do
  before(:all) do
    Role.destroy_all
    FactoryGirl.create(:role_with_super)
    FactoryGirl.create(:role_with_no_super)
  end
  let(:users) do
    20.times {|num| FactoryGirl.create(:user, username: "name#{num}",
                                       email: "name#{num}@polaris.com")}
  end

  context "when user not login" do
    
    describe "GET index" do
      before(:each) {get :index}
      subject {response}
      it {should redirect_to(signin_path)}
    end
  end

  context "when user not login" do
    context "user with super role" do
      let(:user) do
        FactoryGirl.create(:user, role_id: 1)
      end
      before(:each) do
        session[:user_id] = user.id
      end
      describe "GET index" do
        before(:each) {get :index}
        subject {response}
        it {should render_template :index}
      end
    end

    context "user with not super role" do
      let(:user) do
        FactoryGirl.create(:user, role_id: 2)
      end
      before(:each) do
        session[:user_id] = user.id
      end
      describe "GET index" do
        before(:each) {get :index}
        subject {response}
        it {should redirect_to(root_path)}
      end
    end
  end
end
