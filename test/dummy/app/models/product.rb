class Product < ActiveRecord::Base
  attr_accessible :name, :uuid, :categories

  has_and_belongs_to_many :categories

  is_trakable
end
