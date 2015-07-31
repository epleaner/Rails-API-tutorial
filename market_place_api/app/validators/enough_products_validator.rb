class EnoughProductsValidator < ActiveModel::Validator
  def validate record
    record.placements.each do |placement|
      product = placement.product
      if placement.quantity > product.quantity
        record.errors["#{product.title}"] << "Insufficient stock: #{product.quantity} remaining"
      end
    end
  end
end