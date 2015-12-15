require 'test_helper'

class MaintCountersControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => MaintCounter.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    MaintCounter.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    MaintCounter.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to maint_counter_url(assigns(:maint_counter))
  end

  def test_edit
    get :edit, :id => MaintCounter.first
    assert_template 'edit'
  end

  def test_update_invalid
    MaintCounter.any_instance.stubs(:valid?).returns(false)
    put :update, :id => MaintCounter.first
    assert_template 'edit'
  end

  def test_update_valid
    MaintCounter.any_instance.stubs(:valid?).returns(true)
    put :update, :id => MaintCounter.first
    assert_redirected_to maint_counter_url(assigns(:maint_counter))
  end

  def test_destroy
    maint_counter = MaintCounter.first
    delete :destroy, :id => maint_counter
    assert_redirected_to maint_counters_url
    assert !MaintCounter.exists?(maint_counter.id)
  end
end
