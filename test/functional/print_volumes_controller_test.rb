require 'test_helper'

class PrintVolumesControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => PrintVolume.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    PrintVolume.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    PrintVolume.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to print_volume_url(assigns(:print_volume))
  end

  def test_edit
    get :edit, :id => PrintVolume.first
    assert_template 'edit'
  end

  def test_update_invalid
    PrintVolume.any_instance.stubs(:valid?).returns(false)
    put :update, :id => PrintVolume.first
    assert_template 'edit'
  end

  def test_update_valid
    PrintVolume.any_instance.stubs(:valid?).returns(true)
    put :update, :id => PrintVolume.first
    assert_redirected_to print_volume_url(assigns(:print_volume))
  end

  def test_destroy
    print_volume = PrintVolume.first
    delete :destroy, :id => print_volume
    assert_redirected_to print_volumes_url
    assert !PrintVolume.exists?(print_volume.id)
  end
end
