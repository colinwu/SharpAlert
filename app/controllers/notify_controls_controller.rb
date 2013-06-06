class NotifyControlsController < ApplicationController
  def index
    @request = request.env['QUERY_STRING'].sub(/sort=[^&]+&*/,'')
    unless (params[:commit].nil?)
      where_array = Array.new
      condition_array = ['place holder']
      if (not params['name_q'].nil? and not params['name_q'].empty?)
        @name_q = params[:name_q]
        condition_array << @name_q.condition
        where_array << @name_q.where('device_name')
      end
      if(not params['tech_q'].nil? and not params['tech_q'].empty?)
        @tech_q = params[:tech_q]
        condition_array << @tech_q.condition
        where_array << @tech_q.where('tech')
      end
      if(not params['local_q'].nil? and not params['local_q'].empty?)
        @local_q = params[:local_q]
        condition_array << @local_q.condition
        where_array << @local_q.where('local_admin')
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
    @notify_controls = NotifyControl.paginate(:page => params[:page], :include => :client, :order => :device_name, :conditions => condition_array, :per_page => 30)
  end

  def show
    @notify_control = NotifyControl.find(params[:id])
  end

  def new
    @notify_control = NotifyControl.new
  end

  def create
    @notify_control = NotifyControl.new(params[:notify_control])
    if @notify_control.save
      redirect_to @notify_control, :notice => "Successfully created notify control."
    else
      render :action => 'new'
    end
  end

  def batch_edit
    @notify_control = NotifyControl.new
    # @selected contains ids to be used in hidden fields in the batch_edit form.
    unless params[:commit].nil?
      @selected = params[:sel].values
    end
  end

  def batch_update
    notice = "Successfully updated controls."
    params[:sel].values.each do |s|
      @notify_control = NotifyControl.find(s)
      params['notify_control'].keys.each do |a|
        unless params['notify_control'][a].nil? or params['notify_control'][a].empty?
          if params['notify_control'][a] == '-1'
            @notify_control[a] = nil
          else
            @notify_control[a] = params['notify_control'][a]
          end
        end
      end
      @notify_control.save
    end
    redirect_to notify_controls_url, :notice => notice
  end
  
  def edit
    @notify_control = NotifyControl.find(params[:id])
    @device_name = (@notify_control.device_serial == 'default') ? 'Default Settings' : @notify_control.alerts[-1].device_name
    @selected = []
  end

  def update
    @notify_control = NotifyControl.find(params[:id])
    if @notify_control.update_attributes(params[:notify_control])
      redirect_to notify_controls_url, :notice  => "Successfully updated notify control."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @notify_control = NotifyControl.find(params[:id])
    @notify_control.destroy
    redirect_to notify_controls_url, :notice => "Successfully destroyed notify control."
  end
end
