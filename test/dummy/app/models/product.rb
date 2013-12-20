class Product < ActiveRecord::Base
  attr_accessible :name, :uuid

  is_trakable
end
