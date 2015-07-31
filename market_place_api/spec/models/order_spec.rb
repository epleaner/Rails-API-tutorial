require 'rails_helper'

RSpec.describe Order, type: :model do
  let(:order) { FactoryGirl.build :order }
  subject { order }

  it { should respond_to(:total) }
  it { should respond_to(:user_id) }

  it { should validate_presence_of(:user_id) }

  it { should belong_to :user }

  it { should have_many(:placements) }
  it { should have_many(:products).through(:placements) }

  describe '#set_total!' do
    before :each do
      products = [
        FactoryGirl.create(:product, price: 100),
        FactoryGirl.create(:product, price: 85)
      ]

      @placement1 = FactoryGirl.build :placement, product: products[0], quantity: 3
      @placement2 = FactoryGirl.build :placement, product: products[1], quantity: 15

      @order = FactoryGirl.build :order, product_ids: products.map(&:id)

      @order.placements << @placement1
      @order.placements << @placement2
    end

    it 'returns the total product costs' do
      expect{@order.set_total!}.to change{@order.total}.from(0).to(1575)
    end
  end

  describe '#build_placements' do
    before :each do
      @product1 = FactoryGirl.create :product, price: 100, quantity: 5
      @product2 = FactoryGirl.create :product, price: 85, quantity: 10

      @product_orders = [
          { product_id: @product1.id, quantity: 2 },
          { product_id: @product2.id, quantity: 3 }
      ]
    end

    it 'builds 2 placements for the order' do
      expect{ order.build_placements(@product_orders) }.to change{ order.placements.size }.from(0).to(2)
    end

    it 'attaches the quantity to the placements' do
      order.build_placements(@product_orders)
      expect(order.placements.first[:quantity]).to eql @product_orders.first[:quantity]
    end
  end

  describe '#valid?' do
    before do
      @product1 = FactoryGirl.create :product, price: 100, quantity: 5
      @product2 = FactoryGirl.create :product, price: 85, quantity: 10

      @placement1 = FactoryGirl.build :placement, product: @product1, quantity: 3
      @placement2 = FactoryGirl.build :placement, product: @product2, quantity: 15

      @order = FactoryGirl.build :order

      @order.placements << @placement1
      @order.placements << @placement2
    end

    it 'becomes invalid due to insufficient products' do
      expect(@order.valid?).to eql(false)
      expect(@order.errors[@product2[:title]]).to include('Insufficient stock: 10 remaining')
    end
  end

end
