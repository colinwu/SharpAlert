class DevicesController < ApplicationController
  def index
    @request = request.env['QUERY_STRING'].sub(/sort=[^&]+&*/,'')
    unless (params[:commit].nil?)
      where_array = Array.new
      condition_array = ['place holder']
      if (not params['name_q'].nil? and not params['name_q'].empty?)
        @name_q = params[:name_q]
        condition_array << @name_q.condition
        where_array << @name_q.where('devices.name')
      end
      if(not params['model_q'].nil? and not params['model_q'].empty?)
        @model_q = params[:model_q]
        condition_array << @model_q.condition
        where_array << @model_q.where('model')
      end
      if(not params['serial_q'].nil? and not params['serial_q'].empty?)
        @serial_q = params[:serial_q]
        condition_array << @serial_q.condition
        where_array << @serial_q.where('serial')
      end
      if (not params['code_q'].nil? and not params['code_q'].empty?)
        @code_q = params[:code_q]
        where_array << @code_q.where('code')
        condition_array << @code_q.condition
      end
      if (not params['client_q'].nil? and not params['client_q'].empty?)
        @client_q = params[:client_q]
        where_array << @client_q.where('clients.name')
        condition_array << @client_q.condition
      end
      
      unless where_array.empty?
        condition_array[0] = where_array.join(' and ')
      else
        condition_array = []
      end
    end
    @devices = Device.order('devices.name').where(condition_array).paginate(:page => params[:page], :per_page => 30)
  end

  def show
    @device = Device.find(params[:id])
  end

  def new
    @device = Device.new
  end

  # TODO 10-Jun-2013 Turn off batch updates for now. Later make available to update client info only.
  def batch_edit
    @device = Device.new
    # @selected contains ids to be used in hidden fields in the batch_edit form.
    unless params[:commit].nil?
      @selected = params[:sel].values
    end
  end
  
  def batch_update
    notice = "Successfully updated device."
    params[:sel].values.each do |s|
      @device = Device.find(s)
      params['device'].keys.each do |a|
        unless params['device'][a].nil? or params['device'][a].empty?
          if params['device'][a] == '-1'
            @device[a] = nil
          else
            @device[a] = params['device'][a]
          end
        end
      end
      @device.save
    end
    redirect_to devices_url, :notice => notice
  end
  
  def create
    @device = Device.new(params[:device])
    if @device.save
      redirect_to @device, :notice => "Successfully created device."
    else
      render :action => 'new'
    end
  end

  def edit
    @device = Device.find(params[:id])
  end

  def update
    @device = Device.find(params[:id])
    if @device.update_attributes(params[:device])
      redirect_to edit_notify_control_path(@device.notify_control), :notice  => "Successfully updated device."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @device = Device.find(params[:id])
    @device.destroy
    redirect_to devices_url, :notice => "Successfully destroyed device."
  end
end
