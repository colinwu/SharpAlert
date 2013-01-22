require 'test_helper'

class NotifyControlTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert NotifyControl.new.valid?
  end
end
