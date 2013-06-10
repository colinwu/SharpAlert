require 'test_helper'

class DeviceTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Device.new.valid?
  end
end
