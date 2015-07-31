class OrderSerializer < ActiveModel::Serializer
  attributes :id, :total, :products

  has_many :products, serializer: OrderProductSerializer
end
