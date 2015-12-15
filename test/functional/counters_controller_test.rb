require 'test_helper'

class CountersControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => Counter.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    Counter.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    Counter.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to counter_url(assigns(:counter))
  end

  def test_edit
    get :edit, :id => Counter.first
    assert_template 'edit'
  end

  def test_update_invalid
    Counter.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Counter.first
    assert_template 'edit'
  end

  def test_update_valid
    Counter.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Counter.first
    assert_redirected_to counter_url(assigns(:counter))
  end

  def test_destroy
    counter = Counter.first
    delete :destroy, :id => counter
    assert_redirected_to counters_url
    assert !Counter.exists?(counter.id)
  end
end
