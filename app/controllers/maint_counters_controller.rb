class MaintCountersController < ApplicationController
  def index
    @maint_counters = MaintCounter.all
  end

  def show
    @maint_counter = MaintCounter.find(params[:id])
  end

  def new
    @maint_counter = MaintCounter.new
  end

  def create
    @maint_counter = MaintCounter.new(params[:maint_counter])
    if @maint_counter.save
      redirect_to @maint_counter, :notice => "Successfully created maint counter."
    else
      render :action => 'new'
    end
  end

  def edit
    @maint_counter = MaintCounter.find(params[:id])
  end

  def update
    @maint_counter = MaintCounter.find(params[:id])
    if @maint_counter.update_attributes(params[:maint_counter])
      redirect_to @maint_counter, :notice  => "Successfully updated maint counter."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @maint_counter = MaintCounter.find(params[:id])
    @maint_counter.destroy
    redirect_to maint_counters_url, :notice => "Successfully destroyed maint counter."
  end
end
