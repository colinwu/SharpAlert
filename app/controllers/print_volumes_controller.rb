class PrintVolumesController < ApplicationController
  before_action :set_pv, only: [:show, :edit, :update, :destroy]
  
  def index
    @print_volumes = PrintVolume.order(:model).paginate(:page => params[:page], :per_page => 30)
  end

  def show
  end

  def new
    @print_volume = PrintVolume.new
  end

  def create
    @print_volume = PrintVolume.new(pv_params)
    if @print_volume.save
      redirect_to print_volumes_url :notice => "Successfully created print volume."
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @print_volume.update(pv_params)
      redirect_to print_volumes_url :notice  => "Successfully updated print volume."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @print_volume.destroy
    redirect_to print_volumes_url, :notice => "Successfully destroyed print volume."
  end

  private
  
  def set_pv
    @print_volume = PrintVolume.find(params[:id])
  end

  def pv_params
    params.require(:print_volume).permit(:model, :ave_bw, :max_bw, :ave_c, :max_c, :lifetime)
  end
end
