class NotifyControlsController < ApplicationController
  def index
    @notify_controls = NotifyControl.paginate(:page => params[:page], :per_page => 30)
  end

  def show
    @notify_control = NotifyControl.find(params[:id])
  end

  def new
    @notify_control = NotifyControl.new
  end

  def create
    @notify_control = NotifyControl.new(params[:notify_control])
    if @notify_control.save
      redirect_to @notify_control, :notice => "Successfully created notify control."
    else
      render :action => 'new'
    end
  end

  def edit
    @notify_control = NotifyControl.find(params[:id])
  end

  def update
    @notify_control = NotifyControl.find(params[:id])
    if @notify_control.update_attributes(params[:notify_control])
      redirect_to notify_controls_url, :notice  => "Successfully updated notify control."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @notify_control = NotifyControl.find(params[:id])
    @notify_control.destroy
    redirect_to notify_controls_url, :notice => "Successfully destroyed notify control."
  end
end
