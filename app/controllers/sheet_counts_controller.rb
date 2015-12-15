class SheetCountsController < ApplicationController
  def index
    @sheet_counts = SheetCount.all
  end

  def show
    @sheet_count = SheetCount.find(params[:id])
  end

  def new
    @sheet_count = SheetCount.new
  end

  def create
    @sheet_count = SheetCount.new(params[:sheet_count])
    if @sheet_count.save
      redirect_to @sheet_count, :notice => "Successfully created sheet count."
    else
      render :action => 'new'
    end
  end

  def edit
    @sheet_count = SheetCount.find(params[:id])
  end

  def update
    @sheet_count = SheetCount.find(params[:id])
    if @sheet_count.update_attributes(params[:sheet_count])
      redirect_to @sheet_count, :notice  => "Successfully updated sheet count."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @sheet_count = SheetCount.find(params[:id])
    @sheet_count.destroy
    redirect_to sheet_counts_url, :notice => "Successfully destroyed sheet count."
  end
end
