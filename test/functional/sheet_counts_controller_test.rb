require 'test_helper'

class SheetCountsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => SheetCount.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    SheetCount.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    SheetCount.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to sheet_count_url(assigns(:sheet_count))
  end

  def test_edit
    get :edit, :id => SheetCount.first
    assert_template 'edit'
  end

  def test_update_invalid
    SheetCount.any_instance.stubs(:valid?).returns(false)
    put :update, :id => SheetCount.first
    assert_template 'edit'
  end

  def test_update_valid
    SheetCount.any_instance.stubs(:valid?).returns(true)
    put :update, :id => SheetCount.first
    assert_redirected_to sheet_count_url(assigns(:sheet_count))
  end

  def test_destroy
    sheet_count = SheetCount.first
    delete :destroy, :id => sheet_count
    assert_redirected_to sheet_counts_url
    assert !SheetCount.exists?(sheet_count.id)
  end
end
