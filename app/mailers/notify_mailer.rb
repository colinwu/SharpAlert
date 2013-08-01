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

  def new_device(who,dev,from)
    @who = who
    @device = dev
    @from = from
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
  
  def nopv_email(dev)
    @dev = dev
    mail(:to => 'colin@colinwu.ca', :subject => "No recommended print volume data")
  end
  
  def counter_alert(first, last)
    @first = first
    @last = last
    @dev = @first.device
    @days = (@last.status_date - @first.status_date) / 86400.0
    @bw_diff = @last.totalprintbw - @first.totalprintbw
    @bw_ratio = (@bw_diff * 30 / @days) / @dev.print_volume.ave_bw
    @bw_bkgnd = ''
    if (@bw_ratio > 1.5)
      @bw_bkgnd = 'red'
    elsif (@bw_ratio < 1.5 and @bw_ratio >= 1)
      @bw_bkgnd = 'yellow'
    elsif (@bw_ratio < 0.5)
      @bw_bkgnd = 'cyan'
    end
    unless (@dev.print_volume.ave_c.nil? or @dev.print_volume.ave_c == 0)
      @c_diff = (@last.totalprintc.to_i + @last.totalprint1c.to_i + @last.totalprint2c.to_i) - (@first.totalprintc.to_i + @first.totalprint1c.to_i + @first.totalprint2c.to_i)
      @c_ratio = (@c_diff * 30 / @days) / @dev.print_volume.ave_c
      @c_bkgnd = ''
      if (@c_ratio > 1.5)
        @c_bkgnd = 'red'
      elsif (@c_ratio < 1.5 and @c_ratio >= 1)
        @c_bkgnd = 'yellow'
      elsif (@c_ratio < 0.5)
        @c_bkgnd = 'cyan'
      end
    end
    if (@c_ratio < 0 or @bw_ratio < 0 or @c_ratio > 1.5 or @bw_ratio > 1.5)
      mail(:to => @dev.notify_control.tech, :subject => "#{@dev.name}: Utilization alert")
#     else
#       unless (@c_ratio > 1.5 or @c_ratio < 0.5 or @bw_ratio > 1.5 or @bw_ratio < 0.5 )
#         mail(:to => @dev.notify_control.tech, :subject => "MFP utilization alert for #{@dev.name}")
#       end
    end
  end
  
end
