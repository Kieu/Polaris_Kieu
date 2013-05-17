require "spec_helper"

describe ClientsController do
  let(:clients) do
    20.times {|num| FactoryGirl.create(:client, client_name: "Client#{num}",
     department_name: "Client#{num}123")}
  end
  
  context "when user not login" do
    describe "GET index" do
      #let(:user) {FactoryGirl.create(:user, role_id: 1)}
      it "renders signin_path" do
		clients
        get :show, id: Client.first.id
        response.should redirect_to(signin_path)
      end
    end
  end
  
  context "user logged in" do
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
  end
end