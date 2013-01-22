require 'test_helper'

class AlertTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Alert.new.valid?
  end
end
