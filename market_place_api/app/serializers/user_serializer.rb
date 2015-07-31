class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :created_at, :updated_at, :auth_token, :product_ids

  def product_ids
    object.products.map(&:id)
  end
end
