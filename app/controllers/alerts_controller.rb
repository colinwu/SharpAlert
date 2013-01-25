class AlertsController < ApplicationController
  def new
    @alert = Alert.new
  end

  def create
    @alert = Alert.new(params[:alert])
    if @alert.save
      redirect_to alerts_url, :notice => "Successfully created alert."
    else
      render :action => 'new'
    end
  end

  def index
    @num_alerts = Alert.all.count
    @num_devices = Alert.all(:group => 'device_serial').count
    @num_service = Alert.all(:conditions => "alert_msg regexp 'Call for service'").count
    @num_pm = Alert.all(:conditions => "alert_msg regexp 'Maintenance'").count
    
    @request = request.env['QUERY_STRING'].sub(/sort=[^&]+&*/,'')
    if params[:sort].nil?
      sort = 'alert_date'
    else
      sort = "#{params[:sort]},alert_date"
    end
    unless (params[:commit].nil?)
      where_array = Array.new
      condition_array = ['place holder']
      if (not params['name_q'].nil? and not params['name_q'].empty?)
        where_array << 'device_name regexp ?'
        @name_q = params[:name_q]
        condition_array << @name_q
     end
      if(not params['model_q'].nil? and not params['model_q'].empty?)
        where_array << 'device_model regexp ?'
        @model_q = params[:model_q]
        condition_array << @model_q
      end
      if(not params['serial_q'].nil? and not params['serial_q'].empty?)
        where_array << 'device_serial regexp ?'
        @serial_q = params[:serial_q]
        condition_array << @serial_q
      end
      if(not params['msg_q'].nil? and not params['msg_q'].empty?)
        where_array << 'alert_msg regexp ?'
        @msg_q = params[:msg_q]
        condition_array << @msg_q
      end
      if not where_array.empty?
        condition_array[0] = where_array.join(' and ')
        @alerts = Alert.paginate(:page => params[:page], :order => sort, :conditions => condition_array, :per_page => 30)
      else
        @alerts = Alert.paginate(:page => params[:page], :per_page => 30, :order => sort)
      end
    else
      @alerts = Alert.paginate(:page => params[:page], :per_page => 30, :order => sort)
    end
  end
end
