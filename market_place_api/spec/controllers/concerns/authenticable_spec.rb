require 'rails_helper'

class Authentication < ActionController::Base
  include Authenticable
end

describe Authenticable do
  let(:authentication) { Authentication.new }
  subject { authentication }

  describe '#current_user' do
    before do
      @user = FactoryGirl.create :user
      request.headers['Authorization'] = @user.auth_token
      allow(authentication).to receive(:request).and_return(request)
    end

    it 'returns the user from the authorization header' do
      expect(authentication.current_user.auth_token).to eql @user.auth_token
    end
  end

  describe '#authenticate_with_token' do
    before do
      @user = FactoryGirl.create :user
      allow(authentication).to receive(:current_user).and_return(nil)
      allow(authentication).to receive(:render) do |args|
        args
      end
    end

    it 'renders a json error message' do
      expect(authentication.authenticate_with_token![:json][:errors]).to eql 'Not authenticated'
    end

    it 'returns unauthorized status' do
      expect(authentication.authenticate_with_token![:status]).to eql :unauthorized
    end
  end

  describe '#user_signed_in?' do
    context 'when there is a user on session' do
      before do
        @user = FactoryGirl.create :user
        allow(authentication).to receive(:current_user).and_return(@user)
      end

      it 'should return true' do
        expect(authentication.user_signed_in?).to be true
      end
    end

    context 'when there is no user on session' do
      before do
        allow(authentication).to receive(:current_user).and_return(nil)
      end

      it 'should return false' do
        expect(authentication.user_signed_in?).to be false
      end
    end

    context
  end
end