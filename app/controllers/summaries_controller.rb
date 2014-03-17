class SummariesController < ApplicationController
  def index
    @num_alerts = Alert.all.count
    @num_devices = Alert.joins(:device).group('serial','model').where("serial <> 'default'").length
    service = Alert.where("alert_msg regexp 'Call for service'")
    @num_service = service.length
    @last_service = service[-1]
    @service_sent = NotifyControl.order(:service_sent).where("service_sent is not NULL").last
    pm = Alert.where("alert_msg regexp 'Maintenance'")
    @num_pm = pm.length
    @last_pm = pm[-1]
    @pm_sent = NotifyControl.order(:pm_sent).where("pm_sent is not NULL").last
    misfeed = Alert.where("alert_msg regexp 'Misfeed'")
    @num_misfeed = misfeed.length
    @last_misfeed = misfeed[-1]
    @misfeed_sent = NotifyControl.order(:jam_sent).where("jam_sent is not NULL").last
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
    
    unless params[:client].nil?
      client_id = params[:client][:client_id]
      if client_id.nil? or client_id.empty?
        where_clause = "serial <> 'default'"
      else
        where_clause = "serial <> 'default' and client_id = #{client_id}"
        @client_q = Client.find(client_id).name
      end
      @paper = Hash.new
      @misfeed = Hash.new
      @toner_low = Hash.new
      @toner_out = Hash.new
      @service = Hash.new
      @maint = Hash.new
      @waste_warn = Hash.new
      @waste_full = Hash.new
      @first_alert = Hash.new
      @devices_by_name = Device.order(:name).where(where_clause)
      @devices_by_model = Device.group(:model).order(:model).where(where_clause)
      @count_by_model = Device.group(:model).where(where_clause).count
      
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
	@first_alert[key] = d.alerts.order(:created_at).first
      end
      
      @devices_by_model.each do |d|
        @paper[d.model] = Alert.joins(:device).where(["model = ? and alert_msg regexp 'load paper' and #{where_clause}", d.model]).select('alert_date,name')
        @misfeed[d.model] = Alert.joins(:device).where(["model = ? and alert_msg regexp 'misfeed' and #{where_clause}", d.model]).select('alert_date,name')
        @toner_low[d.model] = Alert.joins(:device).where(["model = ? and alert_msg regexp 'toner supply' and #{where_clause}", d.model]).select('alert_date,name')
        @toner_out[d.model] = Alert.joins(:device).where(["model = ? and alert_msg regexp 'Add toner' and #{where_clause}", d.model]).select('alert_date,name')
        @service[d.model] = Alert.joins(:device).where(["model = ? and alert_msg regexp 'service' and #{where_clause}", d.model]).select('alert_date,name')
        @maint[d.model] = Alert.joins(:device).where(["model = ? and alert_msg regexp 'maintenance' and #{where_clause}", d.model]).select('alert_date,name')
        @waste_warn[d.model] = Alert.joins(:device).where(["model = ? and alert_msg regexp 'toner collection container' and #{where_clause}", d.model]).select('alert_date,name')
        @waste_full[d.model] = Alert.joins(:device).where(["model = ? and alert_msg regexp 'replace used toner container' and #{where_clause}", d.model]).select('alert_date,name')
      end
    end
  end
end
