require 'test_helper'

class TrakaTest < ActiveSupport::TestCase
  test "Traka change has latest version" do
    assert_equal TrakaChange.latest_version, 1
  end
end
