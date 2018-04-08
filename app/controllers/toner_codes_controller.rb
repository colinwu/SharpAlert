class TonerCodesController < ApplicationController
  before_action :set_toner_code, only: [:show, :edit, :update, :destroy]
  def index
    @toner_codes = TonerCode.all
  end

  def show
  end

  def new
    @toner_code = TonerCode.new
  end

  def create
    @toner_code = TonerCode.new(toner_code_params)
    if @toner_code.save
      redirect_to @toner_code, :notice => "Successfully created toner code."
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @toner_code.update_attributes(toner_code_params)
      redirect_to @toner_code, :notice  => "Successfully updated toner code."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @toner_code.destroy
    redirect_to toner_codes_url, :notice => "Successfully destroyed toner code."
  end

  private

  def set_toner_code
    @toner_code = TonerCode.find(params[:id])
  end

  def toner_code_params
    params.require(:toner_code).permit(:colour, :alert_id)
  end
end
