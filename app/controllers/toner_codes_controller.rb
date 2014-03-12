class TonerCodesController < ApplicationController
  def index
    @toner_codes = TonerCode.all
  end

  def show
    @toner_code = TonerCode.find(params[:id])
  end

  def new
    @toner_code = TonerCode.new
  end

  def create
    @toner_code = TonerCode.new(params[:toner_code])
    if @toner_code.save
      redirect_to @toner_code, :notice => "Successfully created toner code."
    else
      render :action => 'new'
    end
  end

  def edit
    @toner_code = TonerCode.find(params[:id])
  end

  def update
    @toner_code = TonerCode.find(params[:id])
    if @toner_code.update_attributes(params[:toner_code])
      redirect_to @toner_code, :notice  => "Successfully updated toner code."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @toner_code = TonerCode.find(params[:id])
    @toner_code.destroy
    redirect_to toner_codes_url, :notice => "Successfully destroyed toner code."
  end
end
