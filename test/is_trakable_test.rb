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
    c = Product.new(:name => "Product B")
    c.save
    tc = TrakaChange.last

    assert_equal tc.klass, "Product"
    assert_equal tc.action_type, "create"
  end

  def test_a_product_should_record_changes_on_destroy
    c = Product.new(:name => "Product B")
    c.save
    c.destroy
    tc = TrakaChange.last

    assert_equal tc.klass, "Product"
    assert_equal tc.action_type, "destroy"
  end

  def test_a_product_should_record_changes_on_update
    c = Product.new(:name => "Product B")
    c.save
    c.name = "New Name"
    c.save
    tc = TrakaChange.last

    assert_equal tc.klass, "Product"
    assert_equal tc.action_type, "update"
  end

  def test_a_cheese_should_record_changes_on_create
    c = Cheese.new(:name => "Cheese B")
    c.save
    tc = TrakaChange.last

    assert_equal tc.klass, "Cheese"
    assert_equal tc.action_type, "create"
  end

  def test_a_cheese_should_record_changes_on_destroy
    c = Cheese.new(:name => "Cheese B")
    c.save
    c.destroy
    tc = TrakaChange.last

    assert_equal tc.klass, "Cheese"
    assert_equal tc.action_type, "destroy"
  end

  def test_a_cheese_should_record_changes_on_update
    c = Cheese.new(:name => "Cheese B")
    c.save
    c.name = "New Name"
    c.save
    tc = TrakaChange.last

    assert_equal tc.klass, "Cheese"
    assert_equal tc.action_type, "update"
  end

end
