class ServiceCodesController < ApplicationController
  def index
    @service_codes = ServiceCode.all
  end

  def show
    @service_code = ServiceCode.find(params[:id])
  end

  def new
    @service_code = ServiceCode.new
  end

  def create
    @service_code = ServiceCode.new(params[:service_code])
    if @service_code.save
      redirect_to @service_code, :notice => "Successfully created service code."
    else
      render :action => 'new'
    end
  end

  def edit
    @service_code = ServiceCode.find(params[:id])
  end

  def update
    @service_code = ServiceCode.find(params[:id])
    if @service_code.update_attributes(params[:service_code])
      redirect_to @service_code, :notice  => "Successfully updated service code."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @service_code = ServiceCode.find(params[:id])
    @service_code.destroy
    redirect_to service_codes_url, :notice => "Successfully destroyed service code."
  end
end
