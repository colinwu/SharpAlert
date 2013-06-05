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

  def show
  end
  
  def index
    @request = request.env['QUERY_STRING'].sub(/sort=[^&]+&*/,'')
    if params[:sort].nil?
      sort = 'alerts.id'
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
        where_array << @name_q.where('notify_controls.device_name')
     end
      if(not params['model_q'].nil? and not params['model_q'].empty?)
        @model_q = params[:model_q]
        condition_array << @model_q.condition
        where_array << @model_q.where('notify_controls.device_model')
      end
      if(not params['serial_q'].nil? and not params['serial_q'].empty?)
        @serial_q = params[:serial_q]
        condition_array << @serial_q.condition
        where_array << @serial_q.where('notify_controls.device_serial')
      end
      if(not params['code_q'].nil? and not params['code_q'].empty?)
        @code_q = params[:code_q]
        where_array << @code_q.where('notify_controls.device_code')
        condition_array << @code_q.condition
      end
      if (not params['client_q'].nil? and not params['client_q'].empty?)
        @client_q = params[:client_q]
        where_array << @client_q.where('clients.name')
        condition_array << @client_q.condition
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
    @alerts = Alert.paginate(:page => params[:page], :include => {:notify_control => :client}, :order => sort, :conditions => condition_array, :per_page => 30)
    if (params[:commit] == 'Export')
      @request.sub!(/commit=Export/,'commit=Find')
      csv_data = '"alert data","device name","device_model","serial number","machine code","message"' + "\n"
      Alert.all(:order => sort, :conditions => condition_array, :include => 'notify_control').each do |a|
        csv_data += a.to_csv + "\n"
      end
      send_data(csv_data, :type => "text/csv", :filename => 'alerts.csv', :disposition => "attachment")
    end
  end
  
  def summary
    @num_alerts = Alert.all.count
    @num_devices = Alert.all(:group => 'device_serial').count
    service = Alert.all(:conditions => "alert_msg regexp 'Call for service'")
    @num_service = service.count
    @last_service = service[-1]
    @service_sent = NotifyControl.last :order => :service_sent
    pm = Alert.all(:conditions => "alert_msg regexp 'Maintenance'")
    @num_pm = pm.count
    @last_pm = pm[-1]
    @pm_sent = NotifyControl.last :order => :pm_sent
    misfeed = Alert.all(:conditions => "alert_msg regexp 'Misfeed'")
    @num_misfeed = misfeed.count
    @last_misfeed = misfeed[-1]
    @misfeed_sent = NotifyControl.last :order => :jam_sent
    paper = Alert.all(:conditions => "alert_msg regexp 'load paper'")
    @num_paper = paper.count
    @last_paper = paper[-1]
    @paper_sent = NotifyControl.last :order => :paper_sent
    waste_full = Alert.all(:conditions => "alert_msg regexp 'replace used toner'")
    @num_waste_full = waste_full.count
    @last_waste_full = waste_full[-1]
    @waste_full_sent = NotifyControl.last :order => :waste_full_sent
    waste_warn = Alert.all(:conditions => "alert_msg regexp 'Replacement the toner'")
    @num_waste_warn = waste_warn.count
    @last_waste_warn = waste_warn[-1]
    @waste_warn_sent = NotifyControl.last :order => :waste_almost_full_sent
    toner_out = Alert.all(:conditions => "alert_msg regexp 'Add toner'")
    @num_toner_out = toner_out.count
    @last_toner_out = toner_out[-1]
    @toner_out_sent = NotifyControl.last :order => :toner_empty_sent
    toner_low = Alert.all(:conditions => "alert_msg regexp 'Toner supply is low'")
    @num_toner_low = toner_low.count
    @last_toner_low = toner_low[-1]
    @toner_low_sent = NotifyControl.last :order => :toner_low_sent
    
    @paper = Hash.new
    @misfeed = Hash.new
    @toner_low = Hash.new
    @toner_out = Hash.new
    @service = Hash.new
    @maint = Hash.new
    @waste_warn = Hash.new
    @waste_full = Hash.new
    @devices_by_name = NotifyControl.order(:device_name)
    @devices_by_model = NotifyControl.group(:device_model).order(:device_model)
    
    @devices_by_name.each do |d|
      @paper[d.device_name] = Alert.where(['notify_control_id = ? and alert_msg regexp "load paper"', d.id]).select(:alert_date)
      @misfeed[d.device_name] = Alert.where(['notify_control_id = ? and alert_msg regexp "misfeed"', d.id]).select(:alert_date)
      @toner_low[d.device_name] = Alert.where(['notify_control_id = ? and alert_msg regexp "toner supply is low"', d.id]).select(:alert_date)
      @toner_out[d.device_name] = Alert.where(['notify_control_id = ? and alert_msg regexp "Add toner"', d.id]).select(:alert_date)
      @service[d.device_name] = Alert.where(['notify_control_id = ? and alert_msg regexp "service"', d.id]).select(:alert_date)
      @maint[d.device_name] = Alert.where(['notify_control_id = ? and alert_msg regexp "maintenance"', d.id]).select(:alert_date)
      @waste_warn[d.device_name] = Alert.where(['notify_control_id = ? and alert_msg regexp "toner collection container"', d.id]).select(:alert_date)
      @waste_full[d.device_name] = Alert.where(['notify_control_id = ? and alert_msg regexp "replace used toner container"', d.id]).select(:alert_date)
    end
    
    @devices_by_model.each do |d|
      @paper[d.device_model] = Alert.joins(:notify_control).where(['notify_controls.device_model = ? and alert_msg regexp "load paper"', d.device_model]).select('alert_date,notify_controls.device_name')
      @misfeed[d.device_model] = Alert.joins(:notify_control).where(['notify_controls.device_model = ? and alert_msg regexp "misfeed"', d.device_model]).select('alert_date,notify_controls.device_name')
      @toner_low[d.device_model] = Alert.joins(:notify_control).where(['notify_controls.device_model = ? and alert_msg regexp "toner low"', d.device_model]).select('alert_date,notify_controls.device_name')
      @toner_out[d.device_model] = Alert.joins(:notify_control).where(['notify_controls.device_model = ? and alert_msg regexp "out of toner"', d.device_model]).select('alert_date,notify_controls.device_name')
      @service[d.device_model] = Alert.joins(:notify_control).where(['notify_controls.device_model = ? and alert_msg regexp "service"', d.device_model]).select('alert_date,notify_controls.device_name')
      @maint[d.device_model] = Alert.joins(:notify_control).where(['notify_controls.device_model = ? and alert_msg regexp "maintenance"', d.device_model]).select('alert_date,notify_controls.device_name')
      @waste_warn[d.device_model] = Alert.joins(:notify_control).where(['notify_controls.device_model = ? and alert_msg regexp "toner collection container"', d.device_model]).select('alert_date,notify_controls.device_name')
      @waste_full[d.device_model] = Alert.joins(:notify_control).where(['notify_controls.device_model = ? and alert_msg regexp "replace used toner container"', d.device_model]).select('alert_date,notify_controls.device_name')
    end
  end
end
