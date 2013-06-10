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
      if(not params['code_q'].nil? and not params['code_q'].empty?)
        @code_q = params[:code_q]
        where_array << @code_q.where('code')
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
    @alerts = Alert.joins(:device => :client).where(condition_array).order(sort).paginate(:page => params[:page], :per_page => 30)
    if (params[:commit] == 'Export')
      @request.sub!(/commit=Export/,'commit=Find')
      csv_data = '"alert data","device name","model","serial number","machine code","message"' + "\n"
      Alert.joins(:device => :client).order(sort).where(condition_array).each do |a|
        csv_data += a.to_csv + "\n"
      end
      send_data(csv_data, :type => "text/csv", :filename => 'alerts.csv', :disposition => "attachment")
    end
  end
  
  # TODO rewrite Alert.all(:conditions ...) to Alert.where(...)
  def summary
    @num_alerts = Alert.all.count
    @num_devices = Alert.joins(:device).group('serial','model').length
    service = Alert.where("alert_msg regexp 'Call for service'")
    @num_service = service.length
    @last_service = service[-1]
    @service_sent = NotifyControl.last :order => :service_sent
    pm = Alert.where("alert_msg regexp 'Maintenance'")
    @num_pm = pm.length
    @last_pm = pm[-1]
    @pm_sent = NotifyControl.last :order => :pm_sent
    misfeed = Alert.where("alert_msg regexp 'Misfeed'")
    @num_misfeed = misfeed.length
    @last_misfeed = misfeed[-1]
    @misfeed_sent = NotifyControl.last :order => :jam_sent
    paper = Alert.all(:conditions => "alert_msg regexp 'load paper'")
    @num_paper = paper.length
    @last_paper = paper[-1]
    @paper_sent = NotifyControl.last :order => :paper_sent
    waste_full = Alert.all(:conditions => "alert_msg regexp 'replace used toner'")
    @num_waste_full = waste_full.length
    @last_waste_full = waste_full[-1]
    @waste_full_sent = NotifyControl.last :order => :waste_full_sent
    waste_warn = Alert.all(:conditions => "alert_msg regexp 'Replacement the toner'")
    @num_waste_warn = waste_warn.length
    @last_waste_warn = waste_warn[-1]
    @waste_warn_sent = NotifyControl.last :order => :waste_almost_full_sent
    toner_out = Alert.all(:conditions => "alert_msg regexp 'Add toner'")
    @num_toner_out = toner_out.length
    @last_toner_out = toner_out[-1]
    @toner_out_sent = NotifyControl.last :order => :toner_empty_sent
    toner_low = Alert.all(:conditions => "alert_msg regexp 'Toner supply is low'")
    @num_toner_low = toner_low.length
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
    @devices_by_name = Device.joins(:client).order(:name).where('serial <> "default"')
    @devices_by_model = Device.group(:model).order(:model).where('serial <> "default"')
    @count_by_model = Device.group(:model).where("serial <> 'default'").count
    
    @devices_by_name.each do |d|
      key = "#{d.name}|#{d.model}|#{d.serial}"
      @paper[key] = d.alerts.where('alert_msg regexp "load paper"').select(:alert_date)
      @misfeed[key] = d.alerts.where('alert_msg regexp "misfeed"').select(:alert_date)
      @toner_low[key] = d.alerts.where('alert_msg regexp "toner supply is low"').select(:alert_date)
      @toner_out[key] = d.alerts.where('alert_msg regexp "Add toner"').select(:alert_date)
      @service[key] = d.alerts.where('alert_msg regexp "service"').select(:alert_date)
      @maint[key] = d.alerts.where('alert_msg regexp "maintenance"').select(:alert_date)
      @waste_warn[key] = d.alerts.where('alert_msg regexp "toner collection container"').select(:alert_date)
      @waste_full[key] = d.alerts.where('alert_msg regexp "replace used toner container"').select(:alert_date)
    end
    
    @devices_by_model.each do |d|
      @paper[d.model] = Alert.joins(:device).where(['model = ? and alert_msg regexp "load paper"', d.model]).select('alert_date,name')
      @misfeed[d.model] = Alert.joins(:device).where(['model = ? and alert_msg regexp "misfeed"', d.model]).select('alert_date,name')
      @toner_low[d.model] = Alert.joins(:device).where(['model = ? and alert_msg regexp "toner low"', d.model]).select('alert_date,name')
      @toner_out[d.model] = Alert.joins(:device).where(['model = ? and alert_msg regexp "out of toner"', d.model]).select('alert_date,name')
      @service[d.model] = Alert.joins(:device).where(['model = ? and alert_msg regexp "service"', d.model]).select('alert_date,name')
      @maint[d.model] = Alert.joins(:device).where(['model = ? and alert_msg regexp "maintenance"', d.model]).select('alert_date,name')
      @waste_warn[d.model] = Alert.joins(:device).where(['model = ? and alert_msg regexp "toner collection container"', d.model]).select('alert_date,name')
      @waste_full[d.model] = Alert.joins(:device).where(['model = ? and alert_msg regexp "replace used toner container"', d.model]).select('alert_date,name')
    end
  end
end
