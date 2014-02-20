require 'test_helper'

class MaintCounterTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert MaintCounter.new.valid?
  end
end
