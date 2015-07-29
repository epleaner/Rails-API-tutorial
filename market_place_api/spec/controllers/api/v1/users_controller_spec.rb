require 'rails_helper'

describe Api::V1::UsersController do

  describe 'GET #show' do
    before(:each) do
      @user = FactoryGirl.create :user
      get :show, id: @user.id, format: :json
    end

    it 'returns the information about a reporter on a hash' do
      user_response = json_response
      expect(user_response[:email]).to eq @user.email
    end

    it { should respond_with 200 }
  end

  describe 'POST #create' do
    context 'when created successfully' do
      before(:each) do
        @user_attributes = FactoryGirl.attributes_for :user
        post :create, { user: @user_attributes }
      end

      it 'renders the json representation for the newly created user record' do
        user_response = json_response
        expect(user_response[:email]).to eq @user_attributes[:email]
      end

      it { should respond_with 201 }
    end

    context 'when unsuccessfully created' do
      before(:each) do
        @invalid_user_attributes = FactoryGirl.attributes_for(:user).except(:email)
        post :create, { user: @invalid_user_attributes }
      end

      it 'renders an error json' do
        user_response = json_response
        expect(user_response[:errors][:email]).to include "can't be blank"
      end

      it { should respond_with 422 }
    end
  end

  describe 'PUT/PATCH #update' do
    before(:each) do
      @user = FactoryGirl.create :user
    end

    context 'authorized request' do
      before(:each) do
        api_authorization_header @user.auth_token
      end

      context 'when update is successful' do
        before(:each) do
          patch :update, { id: @user.id,
                           user: { email: 'new@email.com'} }
        end

        it 'renders the json representation for the updated user' do
          user_response = json_response
          expect(user_response[:email]).to eql 'new@email.com'
        end

        it { should respond_with 200 }
      end

      context 'when update is unsuccessful' do
        before(:each) do
          patch :update, { id: @user.id,
                           user: { email: 'bademail.com'} }
        end

        it 'renders the json errors on why the user could not be created' do
          user_response = json_response
          expect(user_response[:errors][:email]).to include 'is invalid'
        end

        it { should respond_with 422 }
      end
    end

    context 'unauthorized request' do
      before(:each) do
        patch :update, { id: @user.id,
                         user: { email: 'new@email.com'} }
      end

      it { should respond_with 401}
    end
  end

  describe 'DELETE #destroy' do
    before(:each) do
      @user = FactoryGirl.create :user
    end

    context 'authorized request' do
      before(:each) do
        api_authorization_header @user.auth_token
      end

      it 'deletes the user from the database' do
        expect{
          delete :destroy, { id: @user.id}
        }.to change(User, :count).by(-1)
      end

      it 'responds with 204' do
        delete :destroy, { id: @user.id}
        expect(response.status).to eql(204)
      end
    end

    context 'unauthorized request' do
      before(:each) do
        delete :destroy, { id: @user.id}
      end

      it { should respond_with 401}
    end
  end
end
