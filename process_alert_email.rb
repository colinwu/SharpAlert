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
      codes = gets
      msg += ": $#{codes}"
    elsif msg =~ /Maintenance required. Code:(.+)$/
      codes = $1
    end
    alert.alert_msg = msg
  elsif line =~ /^(\d{4,4}\/\d{2,2}\/\d{2,2}\s+\d{2,2}:\d{2,2}:\d{2,2})/
    alert.alert_date = $1
  end
end

# retrieve details of the last alert for this device before committing this alert
last_alert = Alert.find_last_by_device_serial alert.device_serial
alert.save

# retrieve (or create using defaults) the notification profile for this device.
n = NotifyControl.find_by_device_serial(alert.device_serial)
if n.nil?
  ndef = NotifyControl.find_by_device_serial 'default'
  n = NotifyControl.new
  n.device_serial = alert.device_serial
  n.who = ndef.who
  n.device_tz = ndef.device_tz
  n.jam = ndef.jam
  n.toner_low = ndef.toner_low
  n.toner_empty = ndef.toner_empty
  n.paper = ndef.paper
  n.service = ndef.service
  n.pm = ndef.pm
  n.waste_almost_full = ndef.waste_almost_full
  n.waste_full = ndef.waste_full
  n.job_log_full = ndef.job_log_full
  n.save
end

# figure out if we need to send notification
if alert.alert_msg =~ /Misfeed/ and not n.jam.nil?
  period = n.jam * 3600
elsif alert.alert_msg =~ /Add toner/ and not n.toner_empty.nil?
  period = n.toner_empty * 3600
elsif alert.alert_msg =~ /Toner supply/i and not n.toner_low.nil?
  period = n.toner_low * 3600
elsif alert.alert_msg =~ /Load paper/ and not n.paper.nil?
  period = n.paper * 3600
elsif alert.alert_msg =~ /Call for service/ and not n.service.nil? and alert.alert_msg == last_alert.alert_msg
  period = n.service * 3600
elsif alert.alert_msg =~ /Maintenance required/ and not n.pm.nil? and alert.alert_msg == last_alert.alert_msg
  period = n.pm * 3600
elsif alert.alert_msg =~ /Replace used toner/ and not n.waste_full.nil?
  period = n.waste_full * 3600
elsif alert.alert_msg =~ /Replacement the toner/ and not n.waste_almost_full.nil?
  period = n.waste_almost_full * 3600
elsif alert.alert_msg =~ /Job/ and not n.job_log_full.nil?
  period = n.job_log_full * 3600
else
  period = nil
end

if not period.nil? and ((alert.alert_date <=> last_alert.alert_date + period) > 0)
  # Send alert
  NotifyMailer.notify_email(n.who, alert).deliver
  exit 0
else
  exit 1
end
  
