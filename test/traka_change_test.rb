require 'test_helper'
 
class TrakaChangeTest < ActiveSupport::TestCase

  def setup
    Traka::Change.destroy_all
    Traka::Change.set_version!(0)
  end

  test "TrakaChange has latest version" do
    assert_equal Traka::Change.latest_version, 0
  end

  test "TrakaChange can publish new version" do
    assert_equal Traka::Change.latest_version, 0

    Traka::Change.publish_new_version!

    assert_equal Traka::Change.latest_version, 1
  end

  test "TrakaChange can list staged changes" do
    p = Product.create(:name => "Product A")
    c = Cheese.create(:name => "Cheese A")

    Traka::Change.publish_new_version!

    p2 = Product.create(:name => "Product B")
    c2 = Cheese.create(:name => "Cheese B")

    assert_equal Traka::Change.changes.count, 2
    assert_equal Traka::Change.changes.first.klass, "Product"
    assert_equal Traka::Change.changes.last.klass, "Cheese"
  end

  test "TrakaChange can list changes from a particular version" do
    p = Product.create(:name => "Product A")
    c = Cheese.create(:name => "Cheese A")

    assert_equal Traka::Change.changes.count, 2

    Traka::Change.publish_new_version!

    p2 = Product.create(:name => "Product B")

    Traka::Change.publish_new_version!

    p3 = Product.create(:name => "Product C")

    assert_equal Traka::Change.changes.count, 1
    assert_equal Traka::Change.changes.first.klass, "Product"

    assert_equal Traka::Change.changes(:version => 1).count, 3 ## Product C is not returned because it hasn't been published.
    assert_equal Traka::Change.changes(:version => 1).map(&:klass), ["Product", "Cheese", "Product"]
    assert_equal Traka::Change.changes(:version => 1).map(&:action_type), ["create", "create", "create"]
  end

  test "TrakaChange can list changes for a particular version" do
    p = Product.create(:name => "Product A")
    c = Cheese.create(:name => "Cheese A")

    assert_equal Traka::Change.changes.count, 2

    Traka::Change.publish_new_version!

    p2 = Product.create(:name => "Product B")

    assert_equal Traka::Change.changes.count, 1
    assert_equal Traka::Change.changes.first.klass, "Product"

    assert_equal Traka::Change.changes(:version => (1..1)).count, 2
    assert_equal Traka::Change.changes(:version => (1..1)).map(&:klass), ["Product", "Cheese"]
    assert_equal Traka::Change.changes(:version => (1..1)).map(&:action_type), ["create", "create"]
  end

  test "TrakaChange can list differing changes" do
    p = Product.create(:name => "Product A")
    c = Cheese.create(:name => "Cheese A")

    Traka::Change.publish_new_version!

    p.name = "New name"
    p.save
    c.destroy

    assert_equal Traka::Change.changes.count, 2
    assert_equal Traka::Change.changes.map(&:klass), ["Product", "Cheese"]
    assert_equal Traka::Change.changes.map(&:action_type), ["update", "destroy"]
  end

  test "TrakaChange can filter out obsolete create->destroy actions" do
    p = Product.create(:name => "Product A")
    c = Cheese.create(:name => "Cheese A")

    p.destroy

    assert_equal Traka::Change.changes.count, 1
    assert_equal Traka::Change.changes.map(&:klass), ["Cheese"]
    assert_equal Traka::Change.changes.map(&:action_type), ["create"]
  end

  test "TrakaChange can filter out obsolete update->destroy actions" do
    p = Product.create(:name => "Product A")
    c = Cheese.create(:name => "Cheese A")

    Traka::Change.publish_new_version!

    p.name = "New name"
    p.save
    c.name = "New name"
    c.save

    p.destroy

    assert_equal Traka::Change.changes.count, 1
    assert_equal Traka::Change.changes.map(&:klass), ["Cheese"]
    assert_equal Traka::Change.changes.map(&:action_type), ["update"]
  end

  test "TrakaChange can filter out obsolete create->update actions" do
    p = Product.create(:name => "Product A")
    c = Cheese.create(:name => "Cheese A")

    p.name = "New name"
    p.save

    p.name = "Another name"
    p.save

    assert_equal Traka::Change.changes.count, 2
    assert_equal Traka::Change.changes.map(&:klass), ["Product", "Cheese"]
    assert_equal Traka::Change.changes.map(&:action_type), ["create", "create"]
  end

  test "TrakaChange can filter out obsolete update->update actions" do
    p = Product.create(:name => "Product A")
    c = Cheese.create(:name => "Cheese A")

    Traka::Change.publish_new_version!

    p.name = "New name"
    p.save

    p.name = "Another name"
    p.save

    p.name = "And another name"
    p.save

    c.name = "New name"
    c.save

    assert_equal Traka::Change.changes.count, 2
    assert_equal Traka::Change.changes.map(&:klass), ["Product", "Cheese"]
    assert_equal Traka::Change.changes.map(&:action_type), ["update", "update"]
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

    # Abridged version would be empty because destroys would cancel out creates and updates.
    assert_equal Traka::Change.changes(:filter => false).count, 6
    assert_equal Traka::Change.changes(:filter => false).map(&:klass), ["Product", "Cheese", "Product", "Product", "Product", "Cheese"]
    assert_equal Traka::Change.changes(:filter => false).map(&:action_type), ["create", "create", "update", "update", "destroy", "destroy"]
  end

  test "TrakaChange can give changes for sub-set of resources" do
    p = Product.create(:name => "Product A")
    c = Cheese.create(:name => "Cheese A")

    p.name = "New name"
    p.save

    c.name = "Another name"
    c.save

    assert_equal Traka::Change.changes(:only => [Product], :filter => false).count, 2
    assert_equal Traka::Change.changes(:only => [Product], :filter => false).map(&:klass), ["Product", "Product"]
    assert_equal Traka::Change.changes(:only => [Product], :filter => false).map(&:action_type), ["create", "update"]
  end

  test "TrakaChange can give changes for sub-set of actions" do
    p = Product.create(:name => "Product A")
    c = Cheese.create(:name => "Cheese A")

    p.name = "New name"
    p.save

    p.name = "Another name"
    p.save

    assert_equal Traka::Change.changes(:actions => [:create]).count, 2
    assert_equal Traka::Change.changes(:actions => [:create]).map(&:klass), ["Product", "Cheese"]
    assert_equal Traka::Change.changes(:actions => [:create]).map(&:action_type), ["create", "create"]
  end

  test "TrakaChange can accept multiple options" do
    p = Product.create(:name => "Product A")
    c = Cheese.create(:name => "Cheese A")

    p.name = "New name"
    p.save

    p.name = "Another name"
    p.save

    p.destroy
    c.destroy

    assert_equal Traka::Change.changes(:actions => [:create], :filter => false, :only => [Product, Cheese]).count, 2
    assert_equal Traka::Change.changes(:actions => [:create], :filter => false, :only => [Product, Cheese]).map(&:klass), ["Product", "Cheese"]
    assert_equal Traka::Change.changes(:actions => [:create], :filter => false, :only => [Product, Cheese]).map(&:action_type), ["create", "create"]

    assert_equal Traka::Change.changes(:actions => [:create, :update], :filter => false).count, 4
    assert_equal Traka::Change.changes(:actions => [:create, :update], :filter => false, :only => [Product, Cheese]).map(&:klass), ["Product", "Cheese", "Product", "Product"]
    assert_equal Traka::Change.changes(:actions => [:create, :update], :filter => false, :only => [Product, Cheese]).map(&:action_type), ["create", "create", "update", "update"]
  end

  test "TrakaChange can handle invalid version Fixnum" do
    p = Product.create(:name => "Product A")
    c = Cheese.create(:name => "Cheese A")

    assert_equal Traka::Change.changes(:version => 4).count, 0
  end

  test "TrakaChange can handle invalid version Range" do
    p = Product.create(:name => "Product A")
    c = Cheese.create(:name => "Cheese A")

    assert_equal Traka::Change.changes(:version => (4..6)).count, 0
  end

  test "TrakaChange can handle invalid version inverted Range" do
    p = Product.create(:name => "Product A")
    c = Cheese.create(:name => "Cheese A")

    assert_equal Traka::Change.changes(:version => (4..0)).count, 0
  end

  test "TrakaChange can resolve AR objects" do
    p = Product.create(:name => "Product A")
    c = Cheese.create(:name => "Cheese A")

    assert_equal Traka::Change.changes.first.get_record, p
    assert_equal Traka::Change.changes.last.get_record, c
  end

end 
