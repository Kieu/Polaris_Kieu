require 'spec_helper'

describe AccountsController do
  let!(:user_super) {FactoryGirl.create(:user_super)}
  let!(:user_client) {FactoryGirl.create(:user_client)}
  let!(:account) {FactoryGirl.create(:account)}

  let(:promotion_id) {1}
  let(:media_id) {1}
  let(:account_name) {"account01"}
  let(:roman_name) {"roman_account01"}
  let(:sync_flg) {1}
  let(:sync_account_id) {"sync_account01"}
  let(:sync_account_pw) {"123123"}
  let(:cost) {100}
  
  let(:action_create) do
    post :create, account: {promotion_id: promotion_id, media_id: media_id,
     account_name: account_name, roman_name: roman_name, sync_flg: sync_flg,
     sync_account_id: sync_account_id, sync_account_pw: sync_account_pw, cost: cost}
  end

  context "when user don't login" do
    describe "GET new" do
      before {get :new}
      subject {response}
      it {should redirect_to signin_path}
    end

    describe "POST create" do
      before {action_create}
      subject {response}
      it {should redirect_to signin_path}
    end
  end

  context "when user logged in" do
    context "with role client" do
      before {session[:user_id] = user_client.id}

      describe "GET new" do
        before {get :new}
        subject {response}
        it {should redirect_to promotions_path}
      end

      describe "POST create" do
        before {action_create}
        subject {response}
        it {should redirect_to promotions_path}
      end
    end

    context "with role super" do
      before {session[:user_id] = user_super.id}  

      describe "GET new" do
        before {get :new}
        subject {response}
        it {should render_template :new}
      end

      describe "POST create" do
        context "with valid params" do
          it "create new account" do
            expect {action_create}.to change(Account, :count).by 1
          end

          it "redirect to promotions path" do
            action_create
            response.should redirect_to promotions_path
          end
        end

        context "with invalid params" do
          before {Account.any_instance.stub(:valid?).and_return false}
          
          it "don't create new account" do
            expect {action_create}.not_to change(Account, :count)
          end

          it "render template new" do
            action_create
            response.should render_template :new
          end
        end
      end
    end
  end
end
