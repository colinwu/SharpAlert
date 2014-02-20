class JamStatsController < ApplicationController
  def index
    @jam_stats = JamStat.all
  end

  def show
    @jam_stat = JamStat.find(params[:id])
  end

  def new
    @jam_stat = JamStat.new
  end

  def create
    @jam_stat = JamStat.new(params[:jam_stat])
    if @jam_stat.save
      redirect_to @jam_stat, :notice => "Successfully created jam stat."
    else
      render :action => 'new'
    end
  end

  def edit
    @jam_stat = JamStat.find(params[:id])
  end

  def update
    @jam_stat = JamStat.find(params[:id])
    if @jam_stat.update_attributes(params[:jam_stat])
      redirect_to @jam_stat, :notice  => "Successfully updated jam stat."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @jam_stat = JamStat.find(params[:id])
    @jam_stat.destroy
    redirect_to jam_stats_url, :notice => "Successfully destroyed jam stat."
  end
end
