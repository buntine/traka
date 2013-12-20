require 'test_helper'
 
class IsTrakableTest < Test::Unit::TestCase
 
  def test_a_products_traka_uuid_should_be_uuid
    assert_equal "uuid", Product.traka_uuid
  end
 
  def test_a_cheeses_traka_uuid_should_be_code
    assert_equal "code", Cheese.traka_uuid
  end

  def test_a_products_uuid_is_set_on_save
    p = Product.new(:name => "Product A")
    p.save

    assert_not_nil p.uuid
    assert_kind_of String, p.uuid
  end

  def test_a_cheeses_code_is_set_on_save
    c = Cheese.new(:name => "Cheese A")
    c.save

    assert_not_nil c.code
    assert_kind_of String, c.code
  end

  def test_a_product_should_record_changes_on_create
    assert true
  end

  def test_a_product_should_record_changes_on_destroy
    assert true
  end

  def test_a_product_should_record_changes_on_update
    assert true
  end

  def test_a_cheese_should_record_changes_on_create
    assert true
  end

  def test_a_cheese_should_record_changes_on_destroy
    assert true
  end

  def test_a_cheese_should_record_changes_on_update
    assert true
  end

end
