require 'test_helper'

class TonerCodesControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => TonerCode.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    TonerCode.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    TonerCode.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to toner_code_url(assigns(:toner_code))
  end

  def test_edit
    get :edit, :id => TonerCode.first
    assert_template 'edit'
  end

  def test_update_invalid
    TonerCode.any_instance.stubs(:valid?).returns(false)
    put :update, :id => TonerCode.first
    assert_template 'edit'
  end

  def test_update_valid
    TonerCode.any_instance.stubs(:valid?).returns(true)
    put :update, :id => TonerCode.first
    assert_redirected_to toner_code_url(assigns(:toner_code))
  end

  def test_destroy
    toner_code = TonerCode.first
    delete :destroy, :id => toner_code
    assert_redirected_to toner_codes_url
    assert !TonerCode.exists?(toner_code.id)
  end
end
