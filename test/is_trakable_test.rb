require 'test_helper'
 
class IsTrakableTest < Test::Unit::TestCase
 
  def test_a_products_traka_uuid_should_be_uuid
    assert_equal "uuid", Product.traka_uuid
  end
 
  def test_a_cheeses_traka_uuid_should_be_code
    assert_equal "code", Cheese.traka_uuid
  end

end
