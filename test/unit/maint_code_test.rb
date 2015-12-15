require 'test_helper'

class MaintCodeTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert MaintCode.new.valid?
  end
end
