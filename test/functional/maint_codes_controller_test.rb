require 'test_helper'

class MaintCodesControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => MaintCode.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    MaintCode.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    MaintCode.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to maint_code_url(assigns(:maint_code))
  end

  def test_edit
    get :edit, :id => MaintCode.first
    assert_template 'edit'
  end

  def test_update_invalid
    MaintCode.any_instance.stubs(:valid?).returns(false)
    put :update, :id => MaintCode.first
    assert_template 'edit'
  end

  def test_update_valid
    MaintCode.any_instance.stubs(:valid?).returns(true)
    put :update, :id => MaintCode.first
    assert_redirected_to maint_code_url(assigns(:maint_code))
  end

  def test_destroy
    maint_code = MaintCode.first
    delete :destroy, :id => maint_code
    assert_redirected_to maint_codes_url
    assert !MaintCode.exists?(maint_code.id)
  end
end
