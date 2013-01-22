class NotifyMailer < ActionMailer::Base
  default from: "sharpmon@seclcsglab.sharpamericas.com"

  def notify_email(who, alert)
    @who = who
    @alert = alert
    n = NotifyControl.find_by_device_serial alert.device_serial
    # figure out which alert this is so we know which control to use
    if alert.alert_msg =~ /Misfeed/ and not n.jam.nil?
      @period = n.jam
    elsif alert.alert_msg =~ /Add toner/ and not n.toner_empty.nil?
      @period = n.toner_empty
    elsif alert.alert_msg =~ /Toner supply/i and not n.toner_low.nil?
      @period = n.toner_low
    elsif alert.alert_msg =~ /Load paper/ and not n.paper.nil?
      @period = n.paper
    elsif alert.alert_msg =~ /Call for service/ and not n.service.nil? and alert.alert_msg == alert.alert_msg
      @period = n.service
    elsif alert.alert_msg =~ /Maintenance required/ and not n.pm.nil? and alert.alert_msg == alert.alert_msg
      @period = n.pm
    elsif alert.alert_msg =~ /Replace used toner/ and not n.waste_full.nil?
      @period = n.waste_full
    elsif alert.alert_msg =~ /Replacement the toner/ and not n.waste_almost_full.nil?
      @period = n.waste_almost_full
    elsif alert.alert_msg =~ /Job/ and not n.job_log_full.nil?
      @period = n.job_log_full
    else
      @period = nil
    end
    unless @period.nil?
      @num_past_alerts = Alert.find( :all, :conditions => ['alert_msg = ? and device_name = ? and alert_date >= ? and alert_date < ?', alert.alert_msg, alert.device_name, alert.alert_date - @period*3600, alert.alert_date]).count
    end
    mail(:to => who, :subject => "#{alert.device_name} - Alert Message - #{alert.alert_msg}")
  end
  
end
