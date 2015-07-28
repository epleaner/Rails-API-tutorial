require 'rails_helper'

describe User do
  before { @user = FactoryGirl.build(:user) }

  subject { @user }

  it { should respond_to(:email) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }

  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email) }
  it { should validate_confirmation_of(:password) }
  it { should allow_value('example@email.com').for(:email)}

  it { should be_valid }

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
end
