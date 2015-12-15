require 'test_helper'

class JamStatTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert JamStat.new.valid?
  end
end
