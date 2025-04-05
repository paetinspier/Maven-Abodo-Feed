class Property < ApplicationRecord
  validates :property_id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :email, presence: true
  validates :unit_bedrooms, numericality: { greater_than_or_equal_to: 0 }
end
