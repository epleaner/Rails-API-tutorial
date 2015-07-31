require "rails_helper"

RSpec.describe OrderMailer, type: :mailer do
  include Rails.application.routes.url_helpers

  describe '.send-confirmation' do
    before :all do
      @order = FactoryGirl.create :order
      @user = @order.user
      @order_mailer = OrderMailer.send_confirmation(@order)
    end

    it 'should be deliver  to the user from the orders passed in' do
      expect(@order_mailer).to deliver_to(@user.email)
    end

    it 'should be sent from no-reply@marketplace.com' do
      expect(@order_mailer).to deliver_from('no-reply@marketplace.com')
    end

    it 'should contain the users message in the mail body' do
      expect(@order_mailer).to have_body_text("Order: ##{@order.id}")
    end

    it 'should have the correct subject' do
      expect(@order_mailer).to have_subject('Order Confirmation')
    end

    it 'should have the products count' do
      expect(@order_mailer).to have_body_text("You ordered #{@order.products.count} products")
    end
  end
end
