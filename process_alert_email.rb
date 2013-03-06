# Parses a Sharp MFP alert email and records it as an Alert object. This program should be
# invoked by one of Procmail's filter rules.
#
# The email has the form
#    2013/01/20 14:50:56
# 
#    Device Name: YR-MF-124
#    Device Model: MX-4101N
# 
#    Serial Number: 0502254100
#    Machine Code: YR-MF-124
# 
#    Device has detected:
# 
#    !!!!! Maintenance required. Code:FK3 !!!!!
alert = Alert.new

# Parse the email
while (line = gets)
  if line =~ /^Device Name: (\S+)/
    alert.device_name = $1
  elsif line =~ /^Device Model: (\S+)/
    alert.device_model = $1
  elsif line =~ /^Serial Number: (\S+)/
    alert.device_serial = $1
  elsif line =~ /^Machine Code: (\S+)/
    alert.device_code = $1
  elsif line =~ /^!!!!! (.+) !!!!!/
    msg = $1
    if msg =~ /Call for service/
      codes = gets.strip
      msg += ": #{codes}"
    elsif msg =~ /Maintenance required. Code:(.+)$/
      codes = $1
    end
    alert.alert_msg = msg
  elsif line =~ /^(\d{4,4}\/\d{2,2}\/\d{2,2}\s+\d{2,2}:\d{2,2}:\d{2,2})/
    alert.alert_date = $1
  end
end

# retrieve details of the last alert for this device before committing this alert
alert.save

# retrieve (or create using defaults) the notification profile for this device.
@n = NotifyControl.find_by_device_serial_and_device_model(alert.device_serial,alert.device_model)
if @n.nil?
  ndef = NotifyControl.find_by_device_serial 'default'
  @n = alert.create_notify_control(
    :device_serial => alert.device_serial,
    :device_model => alert.device_model,
    :who => ndef.who,
    :jam => ndef.jam,
    :toner_low => ndef.toner_low,
    :toner_empty => ndef.toner_empty,
    :paper => ndef.paper,
    :service => ndef.service,
    :pm => ndef.pm,
    :waste_almost_full => ndef.waste_almost_full,
    :waste_full => ndef.waste_full,
    :job_log_full => ndef.job_log_full)
  NotifyMailer.new_device('wuc@sharpsec.com,chapmanc@sharpsec.com',alert,@n).deliver
else
  alert.notify_control_id = @n.id
end
alert.save

# figure out if we need to send notification
if alert.alert_msg =~ /Misfeed/ and not @n.jam.nil?
  period = @n.jam * 3600
  last_time = @n.jam_sent
elsif alert.alert_msg =~ /Add toner/ and not @n.toner_empty.nil?
  period = @n.toner_empty * 3600
  last_time = @n.toner_empty_sent
elsif alert.alert_msg =~ /Toner supply/i and not @n.toner_low.nil?
  period = @n.toner_low * 3600
  last_time = @n.toner_low_sent
elsif alert.alert_msg =~ /Load paper/ and not @n.paper.nil?
  period = @n.paper * 3600
  last_time = @n.paper_sent
elsif alert.alert_msg =~ /Call for service/ and not @n.service.nil?
  period = @n.service * 3600
  last_time = @n.service_sent
elsif alert.alert_msg =~ /Maintenance required/ and not @n.pm.nil?
  period = @n.pm * 3600
  last_time = @n.pm_sent
elsif alert.alert_msg =~ /Replace used toner/ and not @n.waste_full.nil?
  period = @n.waste_full * 3600
  last_time = @n.waste_full_sent
elsif alert.alert_msg =~ /Replacement the toner/ and not @n.waste_almost_full.nil?
  period = @n.waste_almost_full * 3600
  last_time = @n.waste_almost_full_sent
elsif alert.alert_msg =~ /Job/ and not @n.job_log_full.nil?
  period = @n.job_log_full * 3600
  last_time = @n.job_log_full_sent
else
  period = nil
end

if not period.nil? and (last_time.nil? or (alert.alert_date <=> last_time + period) > 0)
  # Send alert
  NotifyMailer.notify_email(@n.who, alert).deliver
  # but do not let Procmail forward a copy
  exit 1
else
  exit 1
end
  
