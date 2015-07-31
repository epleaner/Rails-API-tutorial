require 'rails_helper'

describe User do
  before { @user = FactoryGirl.build(:user) }

  subject { @user }

  it { should respond_to(:email) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:auth_token) }

  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email) }
  it { should validate_uniqueness_of(:auth_token) }
  it { should validate_confirmation_of(:password) }
  it { should allow_value('example@email.com').for(:email)}

  it { should be_valid }

  it { should have_many(:products)}
  it { should have_many(:orders) }

  describe 'when email is not present' do
    before { @user.email = ''}

    it { should_not be_valid}
  end
  describe 'when password is too short' do
    before { @user.password = 'short'}

    it { should_not be_valid}
  end
  describe 'when passwords do not match' do
    before { @user.password = 'password', @user.password_confirmation = 'not_password'}

    it { should_not be_valid}
  end

  describe '#generate_authentication_token!' do
    it 'generates a unique token' do
      allow(Devise).to receive(:friendly_token).and_return('auniquetoken123')
      @user.generate_authentication_token!
      expect(@user.auth_token).to eql 'auniquetoken123'
    end

    it 'generates another token when one already has been taken' do
      allow(Devise).to receive(:friendly_token).and_return('auniquetoken123', 'auniquetoken123', 'adifferenttoken')
      existing_user = FactoryGirl.create(:user)
      @user.generate_authentication_token!
      expect(@user.auth_token).not_to eql existing_user.auth_token
    end
  end

  describe '#products association' do
    before do
      @user.save
      3.times { FactoryGirl.create :product, user: @user}
    end

    it 'destroys the associated products on self destruct' do
      products = @user.products
      @user.destroy
      products.each do |product|
        expect{ Product.find(product) }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe '#orders association' do
    before do
      @user.save
      @order = FactoryGirl.create :order, user: @user
    end

    it 'destroys the order on user destroy' do
      @user.destroy
      expect { Order.find(@order.id) }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
