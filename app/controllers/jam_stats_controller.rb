class JamStatsController < ApplicationController
  before_action :set_js, only: [:show, :edit, :create, :destroy]

  def index
    @jam_stats = JamStat.all
  end

  def show
  end

  def new
    @jam_stat = JamStat.new
  end

  def create
    @jam_stat = JamStat.new(js_params)
    if @jam_stat.save
      redirect_to @jam_stat, :notice => "Successfully created jam stat."
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @jam_stat.update(js_params)
      redirect_to @jam_stat, :notice  => "Successfully updated jam stat."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @jam_stat.destroy
    redirect_to jam_stats_url, :notice => "Successfully destroyed jam stat."
  end

  private

  def set_js
    @jam_stat = JamStat.find(params[:id])
  end

  def js_params
    params.require(:jam_stat).require(:jam_code, :paper_type, :paper_code, :jam_type, :alert_id)
  end
end
