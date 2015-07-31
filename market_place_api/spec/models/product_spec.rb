require 'rails_helper'

RSpec.describe Product, type: :model do
  let(:product) { FactoryGirl.build :product}
  subject { product }

  it { should respond_to(:title) }
  it { should respond_to(:price) }
  it { should respond_to(:published) }
  it { should respond_to(:user_id) }

  it { should have_many(:placements) }
  it { should have_many(:orders).through(:placements) }

  it 'should not be published' do
    expect(product.published).to be false
  end

  it { should validate_presence_of :title }
  it { should validate_presence_of :price }
  it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
  it { should validate_presence_of :user_id }
  it { should belong_to :user }

  describe '.filter_by_title' do
    before :each do
      @product1 = FactoryGirl.create :product, title: 'A plasma TV'
      @product2 = FactoryGirl.create :product, title: 'Second TV'
      @product3 = FactoryGirl.create :product, title: 'Fast laptop'
      @product4 = FactoryGirl.create :product, title: 'CD player'
    end

    context 'when a TV title pattern is sent' do
      it 'returns 2 matching products' do
        expect(Product.filter_by_title('TV')).to match_array([@product1, @product2])
      end
    end
  end

  describe '.above_or_equal_to_price' do
    before :each do
      @product1 = FactoryGirl.create :product, price: 100
      @product2 = FactoryGirl.create :product, price: 50
      @product3 = FactoryGirl.create :product, price: 150
      @product4 = FactoryGirl.create :product, price: 99
    end

    it 'returns the products which are above or equal to the given price' do
      expect(Product.above_or_equal_to_price(100)).to match_array([@product1, @product3])
    end
  end

  describe '.below_or_equal_to_price' do
    before :each do
      @product1 = FactoryGirl.create :product, price: 100
      @product2 = FactoryGirl.create :product, price: 50
      @product3 = FactoryGirl.create :product, price: 150
      @product4 = FactoryGirl.create :product, price: 99
    end

    it 'returns the products which are above or equal to the given price' do
      expect(Product.below_or_equal_to_price(99)).to match_array([@product2, @product4])
    end
  end

  describe '.recent' do
    before :each do
      @product1 = FactoryGirl.create :product, price: 100
      @product2 = FactoryGirl.create :product, price: 50
      @product3 = FactoryGirl.create :product, price: 150
      @product4 = FactoryGirl.create :product, price: 99

      @product2.updated_at += 1.second
      @product2.save
      @product3.updated_at += 2.second
      @product3.save
    end

    it 'returns the records in updated order' do
      ordered = Product.recent
      expect(ordered[0]).to eql @product3
      expect(ordered[1]).to eql @product2
      expect(ordered[2]).to eql @product4
      expect(ordered[3]).to eql @product1
    end
  end

  describe '.search' do
    before :each do
      @product1 = FactoryGirl.create :product, price: 100, title: 'Plasma tv'
      @product2 = FactoryGirl.create :product, price: 200, title: 'Better plasma tv'
      @product3 = FactoryGirl.create :product, price: 25, title: 'piece of shit tv'
      @product4 = FactoryGirl.create :product, price: 50, title: 'Videogame console'
      @product5 = FactoryGirl.create :product, price: 150, title: 'MP3'
      @product6 = FactoryGirl.create :product, price: 99, title: 'Laptop'
    end

    context 'when title "videogame" and min price "100" are set' do
      it 'returns an empty array' do
        search_hash = { keyword: 'videogame', min_price: 100 }
        expect(Product.search(search_hash)).to be_empty
      end
    end

    context 'when title "tv", max price "150", min price "50" are set' do
      it 'returns only product 1' do
        search_hash = { keyword: 'tv', min_price: 50, max_price: 150 }
        expect(Product.search(search_hash)).to match_array([@product1])
      end
    end

    context 'when an empty hash is sent' do
      it 'returns all the products' do
        expect(Product.search({})).to match_array([@product1, @product2, @product3, @product4, @product5, @product6])
      end
    end

    context 'when product_ids is present' do
      it 'returns the product from the ids' do
        search_hash = { product_ids: [@product1.id, @product2.id] }
        expect(Product.search(search_hash)).to match_array([@product1, @product2])
      end
    end
  end
end
