require 'test_helper'

class ServiceCodesControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => ServiceCode.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    ServiceCode.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    ServiceCode.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to service_code_url(assigns(:service_code))
  end

  def test_edit
    get :edit, :id => ServiceCode.first
    assert_template 'edit'
  end

  def test_update_invalid
    ServiceCode.any_instance.stubs(:valid?).returns(false)
    put :update, :id => ServiceCode.first
    assert_template 'edit'
  end

  def test_update_valid
    ServiceCode.any_instance.stubs(:valid?).returns(true)
    put :update, :id => ServiceCode.first
    assert_redirected_to service_code_url(assigns(:service_code))
  end

  def test_destroy
    service_code = ServiceCode.first
    delete :destroy, :id => service_code
    assert_redirected_to service_codes_url
    assert !ServiceCode.exists?(service_code.id)
  end
end
