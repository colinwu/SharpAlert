require 'test_helper'

class NotifyControlsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => NotifyControl.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    NotifyControl.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    NotifyControl.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to notify_control_url(assigns(:notify_control))
  end

  def test_edit
    get :edit, :id => NotifyControl.first
    assert_template 'edit'
  end

  def test_update_invalid
    NotifyControl.any_instance.stubs(:valid?).returns(false)
    put :update, :id => NotifyControl.first
    assert_template 'edit'
  end

  def test_update_valid
    NotifyControl.any_instance.stubs(:valid?).returns(true)
    put :update, :id => NotifyControl.first
    assert_redirected_to notify_control_url(assigns(:notify_control))
  end

  def test_destroy
    notify_control = NotifyControl.first
    delete :destroy, :id => notify_control
    assert_redirected_to notify_controls_url
    assert !NotifyControl.exists?(notify_control.id)
  end
end
