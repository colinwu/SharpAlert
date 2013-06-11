require 'test_helper'

class CounterTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Counter.new.valid?
  end
end
