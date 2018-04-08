class MaintCodesController < ApplicationController
  before_action :set_maint_code, only: [:show, :edit, :update, :destroy]

  def index
    @maint_codes = MaintCode.all
  end

  def show
  end

  def new
    @maint_code = MaintCode.new
  end

  def create
    @maint_code = MaintCode.new(maint_code_params)
    if @maint_code.save
      redirect_to @maint_code, :notice => "Successfully created maint code."
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @maint_code.update(maint_code_params)
      redirect_to @maint_code, :notice  => "Successfully updated maint code."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @maint_code.destroy
    redirect_to maint_codes_url, :notice => "Successfully destroyed maint code."
  end

  private

  def set_maint_code
    @maint_code = MaintCode.find(params[:id])
  end

  def maint_code_params
    params.require(:maint_code).permit(:alert_id, :code)
  end
end
