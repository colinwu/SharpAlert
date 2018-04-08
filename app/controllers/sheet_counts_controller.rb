class SheetCountsController < ApplicationController
  before_action :set_sheet_count, only: [:show, :edit, :update, :destroy]

  def index
    @sheet_counts = SheetCount.all
  end

  def show
  end

  def new
    @sheet_count = SheetCount.new
  end

  def create
    @sheet_count = SheetCount.new(sheet_count_params)
    if @sheet_count.save
      redirect_to @sheet_count, :notice => "Successfully created sheet count."
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @sheet_count.update_attributes(sheet_count_params)
      redirect_to @sheet_count, :notice  => "Successfully updated sheet count."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @sheet_count.destroy
    redirect_to sheet_counts_url, :notice => "Successfully destroyed sheet count."
  end

  private

  def set_sheet_count
    @sheet_count = SheetCount.find(params[:id])
  end

  def sheet_count_params
    params.require(:sheet_count).permit(:bw, :color, :alert_id)
  end

end
