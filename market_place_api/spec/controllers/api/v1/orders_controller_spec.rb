require 'rails_helper'

RSpec.describe Api::V1::OrdersController, type: :controller do
  describe 'GET #index' do
    before :each do
      @current_user = FactoryGirl.create :user
      4.times { FactoryGirl.create :order, user: @current_user }
    end

    context 'when authorized' do
      before :each do
        api_authorization_header @current_user.auth_token
        get :index, user_id: @current_user.id
      end

      it 'returns 4 order records from the user' do
        expect(json_response[:orders].count).to eql 4
      end

      it { should respond_with 200 }
    end

    context 'when unauthorized' do
      before do
        get :index, user_id: @current_user.id
      end

      it { should respond_with 401 }
    end
  end

  describe 'GET #show' do
    before :each do
      @current_user = FactoryGirl.create :user
      @product = FactoryGirl.create :product
      @order = FactoryGirl.create :order, user: @current_user, product_ids: [@product.id]
    end

    context 'when authenticated' do
      before :each do
        api_authorization_header @current_user.auth_token
      end

      context 'when the order exists for the user' do
        before :each do
          get :show, user_id: @current_user.id, id: @order.id
        end

        it 'returns the order' do
          expect(json_response[:order][:id]).to eql @order.id
        end

        it 'includes the total for the order' do
          expect(json_response[:order][:total]).to eql @order.total.to_s
        end

        it 'includes the product list for the order' do
          expect(json_response[:order][:products].count).to eql 1
          expect(json_response[:order][:products].first[:id]).to eql @product.id
        end

        it 'does not include the product user' do
          expect(json_response[:order][:products].first[:user]).to be_nil
        end

        it { should respond_with 200 }
      end

      context 'when the order does not exist for the user' do
        before do
          get :show, user_id: @current_user.id, id: 1000
        end

        it { should respond_with 404 }
      end
    end

    context 'when unauthenticated' do
      before do
        get :show, user_id: @current_user.id, id: @order.id
      end

      it { should respond_with 401 }
    end
  end

  describe 'POST #create' do
    before :each do
      @current_user = FactoryGirl.create :user

      @product1 = FactoryGirl.create :product
      @product2 = FactoryGirl.create :product

      @order_params = { product_orders: [
          {product_id: @product1.id, quantity: 5},
          {product_id: @product2.id, quantity: 3}
      ] }
    end

    context 'when authenticated' do
      before :each do
        api_authorization_header @current_user.auth_token
      end

      it 'sends an email' do
        expect { post :create, order: @order_params }.to change { Delayed::Job.count }.by(1)
        Delayed::Worker.new.work_off
        expect(ActionMailer::Base.deliveries.count).to eql 1
      end

      it 'returns the new order record' do
        post :create, order: @order_params
        expect(json_response[:order][:id]).to be_present
      end

      context 'checking response status' do
        before do
          post :create, order: @order_params
        end

        it { should respond_with 201 }
      end
    end

    context 'when unauthenticated' do
      before do
        post :create, order: @order_params
      end

      it { should respond_with 401 }
    end
  end

end
