class NotifyMailer < ActionMailer::Base
  default from: "sharpmon@seclcsglab.sharpamericas.com"

  def notify_email(who, alert)
    @who = who
    @alert = alert
    @n = NotifyControl.find_by_device_serial alert.device_serial
    # figure out which alert this is so we know which control to use
    if alert.alert_msg =~ /Misfeed/ and not @n.jam.nil?
      @last_sent = @n.jam_sent
      @n.jam_sent = alert.alert_date
    elsif alert.alert_msg =~ /Add toner/ and not @n.toner_empty.nil?
      @last_sent = @n.toner_empty_sent
      @n.toner_empty_sent = alert.alert_date
    elsif alert.alert_msg =~ /Toner supply/i and not @n.toner_low.nil?
      @last_sent = @n.toner_low_sent
      @n.toner_low_sent = alert.alert_date
    elsif alert.alert_msg =~ /Load paper/ and not @n.paper.nil?
      @last_sent = @n.paper_sent
      @n.paper_sent = alert.alert_date
    elsif alert.alert_msg =~ /Call for service/ and not @n.service.nil?
      @last_sent = @n.service_sent
      @n.service_sent = alert.alert_date
    elsif alert.alert_msg =~ /Maintenance required/ and not @n.pm.nil?
      @last_sent = @n.pm_sent
      @n.pm_sent = alert.alert_date
    elsif alert.alert_msg =~ /Replace used toner/ and not @n.waste_full.nil?
      @last_sent = @n.waste_full_sent
      @n.waste_full_sent = alert.alert_date
    elsif alert.alert_msg =~ /Replacement the toner/ and not @n.waste_almost_full.nil?
      @last_sent = @n.waste_almost_full_sent
      @n.waste_almost_full_sent = alert.alert_date
    elsif alert.alert_msg =~ /Job/ and not @n.job_log_full.nil?
      @last_sent = @n.job_log_full_sent
      @n.job_log_full_sent = alert.alert_date
    else
      @last_sent = nil
    end
    unless @last_sent.nil?
      @num_past_alerts = Alert.find( :all, :conditions => ['alert_msg = ? and device_name = ? and alert_date > ? and alert_date < ?', alert.alert_msg, alert.device_name, @last_sent, alert.alert_date]).count
    end
    mail(:to => who, :subject => "#{alert.device_name} - Alert Message - #{alert.alert_msg}")
    @n.save
  end

  def new_device(who,alert,n)
    @who = who
    @alert = alert
    @control = n
    mail(:to => who, :subject => "New device detected")
  end
end
