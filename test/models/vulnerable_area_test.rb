require 'test_helper'

class VulnerableZoneTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test 'geom exists' do
    vulnerable_zone = VulnerableZones.last
    assert_not_nil vulnerable_zone, "Expect not nil. Got : #{vulnerable_area}"
  end
end
