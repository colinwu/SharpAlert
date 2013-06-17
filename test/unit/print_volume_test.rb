require 'test_helper'

class PrintVolumeTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert PrintVolume.new.valid?
  end
end
