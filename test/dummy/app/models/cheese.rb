class Cheese < ActiveRecord::Base
  attr_accessible :code, :name

  is_trakable :traka_uuid => :code
end
