require 'spec_helper'

describe UrlSettingsController do
  let!(:user_super) {FactoryGirl.create(:user_super)}
  let!(:user_client) {FactoryGirl.create(:user_client)}
  let!(:user_agency) {FactoryGirl.create(:user_agency)}
  let!(:client){FactoryGirl.create(:client, id: "1")}
  let!(:account){ FactoryGirl.create(:account, id: "1")}
  let!(:media){ FactoryGirl.create(:media)}
  let!(:promotion) {FactoryGirl.create(:promotion, id: "1")}
  
  context "when user logged in" do
    context "with role super" do
      before {session[:user_id] = user_super.id}

      describe "GET index with no params" do
        before {get :index}
        subject {response}
        it {should render_template "layouts/application"}
      end
    end
  end
end
