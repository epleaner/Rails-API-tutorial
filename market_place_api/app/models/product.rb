class Product < ActiveRecord::Base
  validates :title, :price, :user_id, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0}

  belongs_to :user
end
