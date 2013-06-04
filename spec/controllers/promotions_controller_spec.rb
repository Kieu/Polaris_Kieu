require 'spec_helper'

describe PromotionsController do
  let!(:user_super) {FactoryGirl.create(:user_super)}
  let!(:user_client) {FactoryGirl.create(:user_client)}
  let!(:client) {FactoryGirl.create(:client)}
  let!(:promotion) {FactoryGirl.create(:promotion)}

  let(:promotion_name) {"promotion01"}
  let(:roman_name) {"promotion01"}
  let(:promotion_category_id) {1}
  let(:tracking_period) {10}
  let(:name_to_change) {"change"}

  let(:action_create) do
    post :create, promotion: {promotion_name: promotion_name, roman_name: roman_name,
      promotion_category_id: promotion_category_id, tracking_period: tracking_period,
      agency_id: user_super.company_id}, client_id: client.id
  end
  let(:action_update) do
    put :update, id: promotion.id, promotion: {promotion_name: name_to_change}
  end

  context "when user don't login" do
    describe "GET index" do
      before {get :index}
      subject {response}
      it {should redirect_to signin_path}
    end

    describe "GET show" do
      before {get :show, id: promotion.id}
      subject {response}
      it {should redirect_to signin_path}
    end

    describe "GET new" do
      before {get :new, client_id: client.id}
      subject {response}
      it {should redirect_to signin_path}
    end

    describe "POST create" do
      before {action_create}
      subject {response}
      it {should redirect_to signin_path}
    end

    describe "GET edit" do
      before {get :edit, id: promotion.id}
      subject {response}
      it {should redirect_to signin_path}
    end

    describe "PUT update" do
      before {action_update}
      subject {response}
      it {should redirect_to signin_path}
    end

    describe "delete logically" do
      before {post :delete_promotion, id: promotion.id}
      subject {response}
      it {should redirect_to signin_path}
    end
  end

  context "when user logged in" do
    context "with role client" do
      before {session[:user_id] = user_client.id}

      describe "GET index" do
        before {get :index}
        subject {response}
        it {should render_template :index}
      end

      describe "GET show" do
        before {get :show, id: promotion.id}
        subject {response}
        it {should render_template :index}
      end

      describe "GET new" do
        before {get :new, client_id: client.id}
        subject {response}
        it {should redirect_to promotions_path}
      end

      describe "POST create" do
        before {action_create}
        subject {response}
        it {should redirect_to promotions_path}
      end

      describe "GET edit" do
        before {get :edit, id: promotion.id}
        subject {response}
        it {should redirect_to promotions_path}
      end

      describe "PUT update" do
        before {action_update}
        subject {response}
        it {should redirect_to promotions_path}
      end

      describe "delete logically" do
        before {post :delete_promotion, id: promotion.id}
        subject {response}
        it {should redirect_to promotions_path}
      end
    end

    context "with role super" do
      before {session[:user_id] = user_super.id}

      describe "GET new" do
        before {get :new, client_id: client.id}
        subject {response}
        it {should render_template :new}
      end

      describe "POST create" do
        context "with valid params" do
          it "create new promotion" do
            expect {action_create}.to change(Promotion, :count).by 1
          end

          it "redirect to action new" do
            action_create
            response.should redirect_to action: :new, client_id: client.id
          end
        end

        context "with invalid params" do
          before {Promotion.any_instance.stub(:valid?).and_return false}

          it "don't create new promotion" do
            expect {action_create}.not_to change(Promotion, :count)
          end

          it "render template new" do
            action_create
            response.should render_template :new
          end
        end
      end

      describe "GET edit" do
        before {get :edit, id: promotion.id}
        subject {response}
        it {should render_template :edit}
      end

      describe "PUT update" do
        context "with valid params" do
          before {action_update}

          describe "redirect to action index" do
            subject {response}
            it {should redirect_to action: :index, client_id: promotion.client_id}
          end

          describe "update promotion params" do
            subject {promotion.reload.promotion_name}
            it {should eq name_to_change}
          end
        end

        context "with invalid params" do
          before {Promotion.any_instance.stub(:valid?).and_return false}
          before {action_update}

          describe "render template edit" do
            subject {response}
            it {should render_template :edit}
          end

          describe "don't update promotion params" do
            subject {promotion.reload.promotion_name}
            it {should_not eq name_to_change}
          end
        end
      end

      describe "delete logically" do
        before {post :delete_promotion, id: promotion.id}

        describe "set del_flg to deleted" do
          subject {promotion.reload.del_flg}
          it {should eq Settings.promotion.deleted}
        end

        describe "redirect to action index" do
          subject {response}
          it {should redirect_to action: :index, client_id: promotion.client_id}
        end
      end
    end
  end
end
