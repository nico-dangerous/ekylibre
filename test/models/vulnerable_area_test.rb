require 'test_helper'

class VulnerableAreaTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test 'geom exists' do
    vulnerable_area = VulnerableArea
    assert_not_nil vulnerable_area, "Expect not nil. Got : #{ vulnerable_area }"
    assert_not_nil vulnerable_area.geom, "Expect not nil. Got : #{ vulnerable_area.geom }"

  end
end
