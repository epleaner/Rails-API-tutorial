class Order < ActiveRecord::Base
  validates :user_id, presence: true
  validates_with EnoughProductsValidator

  before_validation :set_total!

  belongs_to :user

  has_many :placements
  has_many :products, through: :placements

  def set_total!
    self.total = placements.map{ |p| p.product.price * p.quantity}.sum
  end

  def build_placements product_orders
    product_orders.each do |product_order|
      self.placements.build(product_id: product_order[:product_id], quantity: product_order[:quantity])
    end
  end
end
