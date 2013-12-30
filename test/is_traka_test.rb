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
    p = Product.create(:name => "Product A")
    c = Cheese.create(:name => "Cheese A")

    TrakaChange.publish_new_version!

    p.name = "New name"
    p.save
    c.destroy

    assert_equal TrakaChange.staged_changes.count, 2
    assert_equal TrakaChange.staged_changes.map(&:klass), ["Product", "Cheese"]
    assert_equal TrakaChange.staged_changes.map(&:action_type), ["update", "destroy"]
  end

  test "TrakaChange can filter out obsolete create->destroy actions" do
    p = Product.create(:name => "Product A")
    c = Cheese.create(:name => "Cheese A")

    p.destroy

    assert_equal TrakaChange.staged_changes.count, 1
    assert_equal TrakaChange.staged_changes.map(&:klass), ["Cheese"]
    assert_equal TrakaChange.staged_changes.map(&:action_type), ["create"]
  end

  test "TrakaChange can filter out obsolete update->destroy actions" do
    p = Product.create(:name => "Product A")
    c = Cheese.create(:name => "Cheese A")

    TrakaChange.publish_new_version!

    p.name = "New name"
    p.save
    c.name = "New name"
    c.save

    p.destroy

    assert_equal TrakaChange.staged_changes.count, 1
    assert_equal TrakaChange.staged_changes.map(&:klass), ["Cheese"]
    assert_equal TrakaChange.staged_changes.map(&:action_type), ["update"]
  end

  test "TrakaChange can filter out obsolete create->update actions" do
    p = Product.create(:name => "Product A")
    c = Cheese.create(:name => "Cheese A")

    p.name = "New name"
    p.save

    p.name = "Another name"
    p.save

    assert_equal TrakaChange.staged_changes.count, 2
    assert_equal TrakaChange.staged_changes.map(&:klass), ["Product", "Cheese"]
    assert_equal TrakaChange.staged_changes.map(&:action_type), ["create", "create"]
  end

  test "TrakaChange can filter out obsolete update->update actions" do
    p = Product.create(:name => "Product A")
    c = Cheese.create(:name => "Cheese A")

    TrakaChange.publish_new_version!

    p.name = "New name"
    p.save

    p.name = "Another name"
    p.save

    p.name = "And another name"
    p.save

    c.name = "New name"
    c.save

    assert_equal TrakaChange.staged_changes.count, 2
    assert_equal TrakaChange.staged_changes.map(&:klass), ["Product", "Cheese"]
    assert_equal TrakaChange.staged_changes.map(&:action_type), ["update", "update"]
  end

  test "TrakaChange can give unabridged list of changes" do
    p = Product.create(:name => "Product A")
    c = Cheese.create(:name => "Cheese A")

    p.name = "New name"
    p.save

    p.name = "Another name"
    p.save

    p.destroy
    c.destroy

    # Abridged version would be empty because destroys would cancel out creates.
    assert_equal TrakaChange.staged_changes(false).count, 6
    assert_equal TrakaChange.staged_changes(false).map(&:klass), ["Product", "Cheese", "Product", "Product", "Product", "Cheese"]
    assert_equal TrakaChange.staged_changes(false).map(&:action_type), ["create", "create", "update", "update", "destroy", "destroy"]
  end

  test "TrakaChange can resolve AR objects" do
    p = Product.create(:name => "Product A")
    c = Cheese.create(:name => "Cheese A")

    assert_equal TrakaChange.staged_changes.first.get_record, p
    assert_equal TrakaChange.staged_changes.last.get_record, c
  end

end 
