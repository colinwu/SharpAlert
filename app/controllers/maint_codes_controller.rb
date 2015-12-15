class MaintCodesController < ApplicationController
  def index
    @maint_codes = MaintCode.all
  end

  def show
    @maint_code = MaintCode.find(params[:id])
  end

  def new
    @maint_code = MaintCode.new
  end

  def create
    @maint_code = MaintCode.new(params[:maint_code])
    if @maint_code.save
      redirect_to @maint_code, :notice => "Successfully created maint code."
    else
      render :action => 'new'
    end
  end

  def edit
    @maint_code = MaintCode.find(params[:id])
  end

  def update
    @maint_code = MaintCode.find(params[:id])
    if @maint_code.update_attributes(params[:maint_code])
      redirect_to @maint_code, :notice  => "Successfully updated maint code."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @maint_code = MaintCode.find(params[:id])
    @maint_code.destroy
    redirect_to maint_codes_url, :notice => "Successfully destroyed maint code."
  end
end
