require 'test_helper'

class ReportControllerTest < ActionController::TestCase
  test "should get misfeed" do
    get :misfeed
    assert_response :success
  end

  test "should get volume" do
    get :volume
    assert_response :success
  end

  test "should get service" do
    get :service
    assert_response :success
  end

  test "should get maintenance" do
    get :maintenance
    assert_response :success
  end

end
