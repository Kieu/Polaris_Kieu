require 'spec_helper'

describe AgenciesController do
  let(:agency) {FactoryGirl.create(:agency)}

  context "when user not login" do
    describe "GET index" do
      before {get :index}
      subject {response}
      it {should redirect_to signin_path}
    end

    describe "GET edit" do
      before {get :edit, id: agency.id}
      subject {response}
      it {should redirect_to signin_path}
    end

    describe "PUT update" do
      let(:name_to_change) {"change"}
      let(:action) do
        put :update, id: agency.id, agency: {agency_name: name_to_change}
      end
      before {action}
      subject {response}
      it {should redirect_to signin_path}
    end
  end

  context "when user logged in" do
    let(:user) {FactoryGirl.create(:user, role_id: 1)}
    before {session[:user_id] = user.id}

    describe "GET index" do
      let(:users) do
        3.times {|num| FactoryGirl.create(:agency, agency_name: "agency_name#{num}")}
      end
      before {get :index}
      subject {response}
      it {should render_template :index}
    end

    describe "GET edit" do
      before {get :edit, id: agency.id}
      subject {response}
      it {should render_template :edit}
    end

    describe "PUT update" do
      let(:name_to_change) {"change"}
      let(:action) do
        put :update, id: agency.id, agency: {agency_name: name_to_change}
      end

      context "with valid params" do
        before {action}
        subject {response}
        it {should redirect_to action: :index}
        subject {Agency.last.reload.agency_name}
        it {should eq name_to_change}
      end

      context "with invalid params" do
        before {put :update, id: agency.id, agency: {agency_name: nil}}
        subject {response}
        it {should render_template :edit}
        subject {Agency.last.reload.agency_name}
        it {should_not be_nil}
      end
    end
  end
end
