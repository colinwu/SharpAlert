require 'test_helper'

class ServiceCodeTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert ServiceCode.new.valid?
  end
end
