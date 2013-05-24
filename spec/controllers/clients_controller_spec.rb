require 'spec_helper'

describe ClientsController do
  let(:clients) do
    20.times {|num| FactoryGirl.create(:client, client_name: "Client#{num}",
      roman_name: "Client#{num}", tel: "123#{num}")}
  end

  context "when user not login" do
    describe "GET index" do
      it "renders signin_path" do
        clients
        get :show, id: Client.first.id
        response.should redirect_to(signin_path)
      end
    end

    describe "GET new" do
      it "renders signin_path" do
        get :new
        response.should redirect_to(signin_path)
      end
    end
    describe "GET edit" do
      let(:client) {FactoryGirl.create :client}
      it "renders signin_path " do
        get :edit, id: client.id
        response.should redirect_to signin_path
      end
    end
    describe "PUT update" do
      let(:client) {FactoryGirl.create(:client)}
      let(:name_to_change) {"change"}
      let(:action) do
        put :update, id: client.id, client: {client_name: name_to_change}
      end
      it "redirect to signin_path" do
        action
        response.should redirect_to signin_path
      end
    end
  end
  
  context "user logged in" do
    let(:user) {FactoryGirl.create(:user, role_id: 1)}
		let(:client) {FactoryGirl.create(:client)}
    before {session[:user_id] = user.id}

    describe "GET index" do
      let(:user) {FactoryGirl.create(:user, role_id: 1)}
      before {session[:user_id] = user.id}
      it "renders client/index page" do
        clients
        Client.all.each do |client|
          5.times {|num| FactoryGirl.create(:promotion, client_id: client.id,
          promotion_name: "#{client.id}testPro#{num}")}
        end

        clientss = Client.all
        promotions = Array.new
        clientss.each do |client|
          client.promotions.each do |promotion|
            promotions << promotion
          end
        end

        promotions.count.should eq(100)
        get :index
        response.should render_template :index
      end
    end

    describe "GET new" do
      it "show create client page" do
        get :new
        response.should render_template :new
      end
    end
    #get edit action
    describe "GET edit" do
			it "show edit client page" do
        get :edit, id: client.id
        response.should render_template :edit
			end
    end
    #put update action
    describe "PUT update" do
      let(:client) {FactoryGirl.create(:client)}
      let(:name_to_change) {"change"}
      let(:action) do
        put :update, id: client.id, client: {client_name: name_to_change}
      end
      context "with valid params" do
          before(:each) {action}
          subject {response}
          it {should redirect_to new_client_path}
          subject {Client.last.reload.client_name}
          it{should eq name_to_change}
      end
      context "with invalid params" do
        before(:each) {put :update, id: client.id, client: {client_name: nil}}
        before {Client.any_instance.stub(:valid?).and_return false}
        before {action}
        subject {response}
        it{should render_template :edit}
        subject {Client.last.reload.client_name}
        it{should_not eq name_to_change}
      end
    end

    describe "POST create" do
      let(:client_name) {"client01"}
      let(:roman_name) {"client01"}
      let(:tel) {"123456789"}
      let(:person_charge) {"person01"}
      let(:person_sale) {"person02"}
      let(:contract_flg) {0}
      let(:contract_type) {0}
      let(:action) do
        post :create, client: {client_name: client_name, roman_name: roman_name,
          tel: tel, person_charge: person_charge, person_sale: person_sale,
          contract_flg: contract_flg, contract_type: contract_type}
      end

      context "with valid params" do
        it "create new client" do
          expect {action}.to change(Client, :count).by 1
        end

        it "redirect to new action" do
          action
          response.should redirect_to action: :new
        end
      end

      context "with invalid params" do
        before {Client.any_instance.stub(:valid?).and_return false}
        it "doesn't create new client" do
          expect {action}.not_to change(Client, :count)
        end

        it "render new action" do
          action
          response.should render_template :new
        end
      end
    end
	end
end
