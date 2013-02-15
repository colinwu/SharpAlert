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
    service_alerts = Alert.all(:conditions => "alert_msg regexp 'Call for service'")
    @num_service = service_alerts.count
    @last_service = service_alerts[-1]
    pm_alerts = Alert.all(:conditions => "alert_msg regexp 'Maintenance'")
    @num_pm = pm_alerts.count
    @last_pm = pm_alerts[-1]
    
    @request = request.env['QUERY_STRING'].sub(/sort=[^&]+&*/,'')
    if params[:sort].nil?
      sort = 'alert_date'
    else
      sort = "#{params[:sort]},alert_date"
    end
    unless (params[:commit].nil?)
      where_array = Array.new
      condition_array = ['place holder']
      if (not params['date_q'].nil? and not params['date_q'].empty?)
        @date_q = params[:date_q]
        condition_array << @date_q.condition
        where_array << @date_q.where('alert_date')
      end
      if (not params['name_q'].nil? and not params['name_q'].empty?)
        @name_q = params[:name_q]
        condition_array << @name_q.condition
        where_array << @name_q.where('device_name')
     end
      if(not params['model_q'].nil? and not params['model_q'].empty?)
        @model_q = params[:model_q]
        condition_array << @model_q.condition
        where_array << @model_q.where('device_model')
      end
      if(not params['serial_q'].nil? and not params['serial_q'].empty?)
        @serial_q = params[:serial_q]
        condition_array << @serial_q.condition
        where_array << @serial_q.where('device_serial')
      end
      if(not params['code_q'].nil? and not params['code_q'].empty?)
        @code_q = params[:code_q]
        where_array << @code_q.where('device_code')
        condition_array << @code_q.condition
      end
      if(not params['msg_q'].nil? and not params['msg_q'].empty?)
        @msg_q = params[:msg_q]
        where_array << @msg_q.where('alert_msg')
        condition_array << @msg_q.condition
      end
      unless where_array.empty?
        condition_array[0] = where_array.join(' and ')
      else
        condition_array = []
      end
    end
    @alerts = Alert.paginate(:page => params[:page], :order => sort, :conditions => condition_array, :per_page => 30)
    if (params[:commit] == 'Export')
      @request.sub!(/commit=Export/,'commit=Find')
      csv_data = '"alert data","device name","device_model","serial number","machine code","message"' + "\n"
      Alert.all(:order => sort, :conditions => condition_array).each do |a|
        csv_data += a.to_csv + "\n"
      end
      send_data(csv_data, :type => "text/csv", :filename => 'alerts.csv', :disposition => "attachment")
    end
  end
end
