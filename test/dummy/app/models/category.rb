class Category < ActiveRecord::Base
  attr_accessible :name, :uuid

  has_and_belongs_to_many :products

  is_trakable
end
