require 'rails_helper'

RSpec.describe Api::V1::ProductsController, type: :controller do
  describe 'GET #show' do
    context 'product exists' do
      before(:each) do
        @product = FactoryGirl.create :product
        get :show, id: @product.id
      end

      it 'returns the info about a product on a hash' do
        expect(json_response[:title]).to eql @product.title
      end

      it { should respond_with 200 }
    end

    context 'product does not exist' do
      before(:each) do
        get :show, id: 1000
      end

      it { should respond_with 404 }
    end
  end

  describe 'GET #index' do
    before(:each) do
      4.times { FactoryGirl.create :product }
      get :index
    end

    it 'returns 4 records from the database' do
      expect(json_response[:products].length).to be 4
    end

    it { should respond_with 200 }
  end

  describe 'POST #create' do
    before(:each) do
      @user = FactoryGirl.create :user
    end

    context 'when authenticated' do
      before(:each) do
        api_authorization_header @user.auth_token
      end

      context 'when successfully created' do
        before(:each) do
          @product_attributes = FactoryGirl.attributes_for :product
          post :create, { product: @product_attributes}
        end

        it 'renders the json representation for the product record just created' do
          expect(json_response[:title]).to eql @product_attributes[:title]
        end

        it { should respond_with 201 }
      end

      context 'when unsuccessfully created' do
        before(:each) do
          @invalid_product_attributes = { title: 'product1', price: 'tree fiddy'}
          post :create, { product: @invalid_product_attributes}
        end

        it 'renders the json errors on why the user could not be created' do
          expect(json_response[:errors][:price]).to include 'is not a number'
        end

        it { should respond_with 422 }
      end
    end

    context 'when unauthenticated' do
      before(:each) do
        @product_attributes = FactoryGirl.attributes_for :product
        post :create, { user_id: @user.id, product: @product_attributes}
      end

      it { should respond_with 401 }
    end
  end

  describe 'PUT/PATCH #update' do
    before(:each) do
      @user = FactoryGirl.create :user
    end

    context 'when authorized' do
      before(:each) do
        @product = FactoryGirl.create :product, user: @user
        api_authorization_header @user.auth_token
      end

      context 'when update is successful' do
        before(:each) do
          patch :update, { id: @product.id,
                           product: { title: 'Updated product'}}
        end

        it 'renders the json representation for the updated user' do
          expect(json_response[:title]).to eql 'Updated product'
        end

        it { should respond_with 200 }
      end

      context 'when paramters are incorrect' do
        before(:each) do
          patch :update, { id: @product.id,
                           product: { price: 'tree fiddy'} }
        end

        it 'renders the json errors on why the product could not be created' do
          expect(json_response[:errors][:price]).to include 'is not a number'
        end

        it { should respond_with 422 }
      end

      context 'when product does not belong to user' do
        before(:each) do
          @other_user = FactoryGirl.create :user
          @other_product = FactoryGirl.create :product, user: @other_user
          patch :update, { id: @other_product.id,
                           product: { price: 3.50} }
        end

        it { should respond_with 404 }
      end
    end

    context 'when unauthorized' do
      before :each do
        @product = FactoryGirl.create :product, user: @user
        patch :update, { id: @product.id,
                         product: { title: 'Updated product'}}
      end

      it { should respond_with 401 }
    end
  end

  describe 'DELETE #destroy' do
    before :each do
      @user = FactoryGirl.create :user
      @product = FactoryGirl.create :product, user: @user
    end

    context 'when authorized' do
      before :each do
        api_authorization_header @user.auth_token
      end

      context 'when product belongs to user' do
        before :each do
          delete :destroy, { id: @product.id }
        end

        it 'should remove the product from the db' do
          expect{ Product.find(@product.id) }.to raise_error ActiveRecord::RecordNotFound
        end

        it { should respond_with 204 }
      end

      context 'when product exists but does not belong to user' do
        before do
          @other_user = FactoryGirl.create :user
          @other_product = FactoryGirl.create :product, user: @other_user
          delete :destroy, { id: @other_product.id }
        end

        it { should respond_with 404 }
      end

      context 'when product does not exist' do
        before do
          delete :destroy, { id: 10000 }
        end

        it { should respond_with 404 }
      end

    end

    context 'when unauthorized' do
      before :each do
        delete :destroy, { id: @product.id }
      end

      it { should respond_with 401 }
    end
  end
end
