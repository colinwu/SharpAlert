require 'test_helper'

class TonerCodeTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert TonerCode.new.valid?
  end
end
