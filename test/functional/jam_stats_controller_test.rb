require 'test_helper'

class JamStatsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => JamStat.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    JamStat.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    JamStat.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to jam_stat_url(assigns(:jam_stat))
  end

  def test_edit
    get :edit, :id => JamStat.first
    assert_template 'edit'
  end

  def test_update_invalid
    JamStat.any_instance.stubs(:valid?).returns(false)
    put :update, :id => JamStat.first
    assert_template 'edit'
  end

  def test_update_valid
    JamStat.any_instance.stubs(:valid?).returns(true)
    put :update, :id => JamStat.first
    assert_redirected_to jam_stat_url(assigns(:jam_stat))
  end

  def test_destroy
    jam_stat = JamStat.first
    delete :destroy, :id => jam_stat
    assert_redirected_to jam_stats_url
    assert !JamStat.exists?(jam_stat.id)
  end
end
