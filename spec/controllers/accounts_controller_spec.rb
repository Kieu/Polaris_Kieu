require 'spec_helper'

describe AccountsController do

  context "when user not login" do
    
    describe "GET new" do
      before {get :new}
      subject {response}
      it {should redirect_to signin_path}
    end
  end

  context "when user logged in" do
    let(:user) {FactoryGirl.create(:user, role_id: 1)}
    let(:account) {FactoryGirl.create(:account)}
    before {session[:user_id] = user.id}  

    describe "GET new" do
      before {get :new}
      subject {response}
      it {should render_template :new}
    end

    describe "POST create" do
      let(:promotion_id) {1}
      let(:media_id) {1}
      let(:account_name) {"account01"}
      let(:roman_name) {"roman_account01"}
      let(:sync_flg) {1}
      let(:sync_account_id) {"sync_account01"}
      let(:sync_account_pw) {"123123"}
      let(:cost) {100}
      
      let(:action) do
        post :create, account: {promotion_id: promotion_id, media_id: media_id,
         account_name: account_name, roman_name: roman_name, sync_flg: sync_flg,
         sync_account_id: sync_account_id, sync_account_pw: sync_account_pw, cost: cost}
      end

      context "with valid params" do
        describe "create new account" do
          subject {response}
          it {expect {action}.to change(Account, :count).by 1}
        end

        describe "redirect to new action" do
          before {action}
          subject {response}
          it {should redirect_to action: :new}
        end
      end

      context "with invalid params" do
        before {Account.any_instance.stub(:valid?).and_return false}
        
        describe "doesn't create new account" do
          subject {response}
          it {expect {action}.not_to change(Account, :count)}
        end

        describe "render to new action" do
          before {action}
          subject {response}
          it {should render_template :new}
        end
      end
    end
  end
end
