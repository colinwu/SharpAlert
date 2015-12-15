require 'test_helper'

class SheetCountTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert SheetCount.new.valid?
  end
end
