class ServiceCodesController < ApplicationController
  before_action :set_service_code, only: [:show, :edit, :update, :destroy]
  def index
    @service_codes = ServiceCode.all
  end

  def show
  end

  def new
    @service_code = ServiceCode.new
  end

  def create
    @service_code = ServiceCode.new(service_code_params)
    if @service_code.save
      redirect_to @service_code, :notice => "Successfully created service code."
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @service_code.update_attributes(service_code_params)
      redirect_to @service_code, :notice  => "Successfully updated service code."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @service_code.destroy
    redirect_to service_codes_url, :notice => "Successfully destroyed service code."
  end

  private

  def set_service_code
    @service_code = ServiceCode.find(params[:id])
  end
  
  def service_code_params
    params.require(:service_code).permit(:code, :alert_id)
  end
end
