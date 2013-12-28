require 'test_helper'
 
class IsTrakaTest < ActiveSupport::TestCase

  def setup
    TrakaChange.destroy_all
    TrakaChange.set_version!(1)
  end

  test "TrakaChange has latest version" do
    assert_equal TrakaChange.latest_version, 1
  end

  test "TrakaChange can publish new version" do
    assert_equal TrakaChange.latest_version, 1

    TrakaChange.publish_new_version!

    assert_equal TrakaChange.latest_version, 2
  end

  test "TrakaChange can list staged changes" do
    p = Product.create(:name => "Product A")
    c = Cheese.create(:name => "Cheese A")

    assert_equal TrakaChange.staged_changes.count, 2
    assert_equal TrakaChange.staged_changes.first.klass, "Product"
    assert_equal TrakaChange.staged_changes.last.klass, "Cheese"
  end

  test "TrakaChange can list changes from a particular version" do
    p = Product.create(:name => "Product A")
    c = Cheese.create(:name => "Cheese A")

    assert_equal TrakaChange.staged_changes.count, 2

    TrakaChange.publish_new_version!

    p2 = Product.create(:name => "Product B")

    assert_equal TrakaChange.staged_changes.count, 1
    assert_equal TrakaChange.staged_changes.first.klass, "Product"

    assert_equal TrakaChange.changes_from(1).count, 3
    assert_equal TrakaChange.changes_from(1).map(&:klass), ["Product", "Cheese", "Product"]
    assert_equal TrakaChange.changes_from(1).map(&:action_type), ["create", "create", "create"]
  end

  test "TrakaChange can list differing changes" do
    assert true
  end

  test "TrakaChange can filter out obsolete create/destroy actions" do
    assert true
  end

  test "TrakaChange can filter out obsolete update/destroy actions" do
    assert true
  end

  test "TrakaChange can filter out obsolete multiple update actions" do
    assert true
  end

end 
