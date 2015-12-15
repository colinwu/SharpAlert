class PrintVolumesController < ApplicationController
  def index
    @print_volumes = PrintVolume.order(:model).paginate(:page => params[:page], :per_page => 30)
  end

  def show
    @print_volume = PrintVolume.find(params[:id])
  end

  def new
    @print_volume = PrintVolume.new
  end

  def create
    @print_volume = PrintVolume.new(params[:print_volume])
    if @print_volume.save
      redirect_to print_volumes_url :notice => "Successfully created print volume."
    else
      render :action => 'new'
    end
  end

  def edit
    @print_volume = PrintVolume.find(params[:id])
  end

  def update
    @print_volume = PrintVolume.find(params[:id])
    if @print_volume.update_attributes(params[:print_volume])
      redirect_to print_volumes_url :notice  => "Successfully updated print volume."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @print_volume = PrintVolume.find(params[:id])
    @print_volume.destroy
    redirect_to print_volumes_url, :notice => "Successfully destroyed print volume."
  end
end
