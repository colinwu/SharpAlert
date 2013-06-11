class NotifyMailer < ActionMailer::Base
  default from: "sharpmon@seclcsglab.sharpamericas.com"

  def notify_email(alert)
    @alert = alert
    @n = Device.find(@alert.device_id).notify_control
    # figure out which alert this is so we know which control to use
    if alert.alert_msg =~ /Misfeed/ and not @n.jam.nil?
      @last_sent = @n.jam_sent
      @who = @n.local_admin
      @n.jam_sent = alert.alert_date
    elsif alert.alert_msg =~ /Add toner/ and not @n.toner_empty.nil?
      @last_sent = @n.toner_empty_sent
      @who = @n.local_admin
      @n.toner_empty_sent = alert.alert_date
    elsif alert.alert_msg =~ /Toner supply/i and not @n.toner_low.nil?
      @last_sent = @n.toner_low_sent
      @who = @n.local_admin
      @n.toner_low_sent = alert.alert_date
    elsif alert.alert_msg =~ /Load paper/ and not @n.paper.nil?
      @last_sent = @n.paper_sent
      @who = @n.local_admin
      @n.paper_sent = alert.alert_date
    elsif alert.alert_msg =~ /Call for service/ and not @n.service.nil?
      @last_sent = @n.service_sent
      @who = @n.tech
      @n.service_sent = alert.alert_date
    elsif alert.alert_msg =~ /Maintenance required/ and not @n.pm.nil?
      @last_sent = @n.pm_sent
      @who = @n.tech
      @n.pm_sent = alert.alert_date
    elsif alert.alert_msg =~ /Replace used toner/ and not @n.waste_full.nil?
      @last_sent = @n.waste_full_sent
      @who = @n.local_admin
      @n.waste_full_sent = alert.alert_date
    elsif alert.alert_msg =~ /Replacement the toner/ and not @n.waste_almost_full.nil?
      @last_sent = @n.waste_almost_full_sent
      @who = @n.local_admin
      @n.waste_almost_full_sent = alert.alert_date
    elsif alert.alert_msg =~ /Job/ and not @n.job_log_full.nil?
      @last_sent = @n.job_log_full_sent
      @who = @n.local_admin
      @n.job_log_full_sent = alert.alert_date
    else
      @last_sent = nil
    end
    unless @last_sent.nil?
      @num_past_alerts = Alert.joins(:device).where(['alert_msg = ? and devices.name = ? and alert_date > ? and alert_date < ?', alert.alert_msg, alert.device.name, @last_sent, alert.alert_date]).count
    end
    mail(:to => @who, :subject => "#{alert.device.name} - Alert Message - #{alert.alert_msg}")
    @n.save
  end

  def new_device(who,alert,n)
    @who = who
    @alert = alert
    @control = n
    mail(:to => who, :subject => "New device detected")
  end

  def email_response(who,csv_file)
    attachments['alerts.csv'] = File.read(csv_file)
    mail(:to => who, :subject => "Device alerts you requested")
  end

  def email_response_error(who,error)
    @error = error
    mail(:to => who, :subject => "Could not process your request")
  end
end
