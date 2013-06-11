class CountersController < ApplicationController
  def index
    @counters = Counter.all
  end

  def show
    @counter = Counter.find(params[:id])
  end

  def new
    @counter = Counter.new
  end

  def create
    @counter = Counter.new(params[:counter])
    if @counter.save
      redirect_to @counter, :notice => "Successfully created counter."
    else
      render :action => 'new'
    end
  end

  def edit
    @counter = Counter.find(params[:id])
  end

  def update
    @counter = Counter.find(params[:id])
    if @counter.update_attributes(params[:counter])
      redirect_to @counter, :notice  => "Successfully updated counter."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @counter = Counter.find(params[:id])
    @counter.destroy
    redirect_to counters_url, :notice => "Successfully destroyed counter."
  end
end
