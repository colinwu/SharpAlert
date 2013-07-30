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
  if line =~ /^Device Name: (.+)/i
    name = $1
  elsif line =~ /^Device Model: (.+)/i
    model = $1
  elsif line =~ /^Serial Number: (\S+)/i
    serial = $1
  elsif line =~ /^Machine Code: (.+)/i
    code = $1
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
  elsif line =~ /^From: (.+)/
    from = $1
  end
end

# retrieve details of the last alert for this device before committing this alert
alert.save

# TODO figure out how to do create_notify_control after removing "belongs_to notify_control" from Alerts.rb
# retrieve (or create using defaults) the notification profile for this device.
@d = Device.find_by_serial_and_model(serial,model)
if @d.nil?
  ndef = Device.find_by_serial('default').notify_control
  @d = alert.create_device(
    :serial => serial,
    :model => model,
    :name => name,
    :code => code)
  @n = @d.create_notify_control(
    :tech => ndef.tech,
    :local_admin => ndef.local_admin,
    :jam => ndef.jam,
    :toner_low => ndef.toner_low,
    :toner_empty => ndef.toner_empty,
    :paper => ndef.paper,
    :service => ndef.service,
    :pm => ndef.pm,
    :waste_almost_full => ndef.waste_almost_full,
    :waste_full => ndef.waste_full,
    :job_log_full => ndef.job_log_full)
  NotifyMailer.new_device('wuc@sharpsec.com',@d,from).deliver
else
  alert.device_id = @d.id
  @n = @d.notify_control
end
alert.save

# figure out if we need to send notification
if alert.alert_msg =~ /Misfeed/ and not @n.jam.nil?
  period = @n.jam * 3600
  last_time = @n.jam_sent
  send_to = @n.local_admin
elsif alert.alert_msg =~ /Add toner/ and not @n.toner_empty.nil?
  period = @n.toner_empty * 3600
  last_time = @n.toner_empty_sent
  send_to = @n.local_admin
elsif alert.alert_msg =~ /Toner supply/i and not @n.toner_low.nil?
  period = @n.toner_low * 3600
  last_time = @n.toner_low_sent
  send_to = @n.local_admin
elsif alert.alert_msg =~ /Load paper/ and not @n.paper.nil?
  period = @n.paper * 3600
  last_time = @n.paper_sent
  send_to = @n.local_admin
elsif alert.alert_msg =~ /Call for service/ and not @n.service.nil?
  period = @n.service * 3600
  last_time = @n.service_sent
  send_to = @n.tech
elsif alert.alert_msg =~ /Maintenance required/ and not @n.pm.nil?
  period = @n.pm * 3600
  last_time = @n.pm_sent
  send_to = @n.tech
elsif alert.alert_msg =~ /Replace used toner/ and not @n.waste_full.nil?
  period = @n.waste_full * 3600
  last_time = @n.waste_full_sent
  send_to = @n.local_admin
elsif alert.alert_msg =~ /Replacement the toner/ and not @n.waste_almost_full.nil?
  period = @n.waste_almost_full * 3600
  last_time = @n.waste_almost_full_sent
  send_to = @n.local_admin
elsif alert.alert_msg =~ /Job/ and not @n.job_log_full.nil?
  period = @n.job_log_full * 3600
  last_time = @n.job_log_full_sent
  send_to = nil
else
  period = nil
  send_to = nil
end

if not send_to.nil? and not period.nil? and (last_time.nil? or (alert.alert_date <=> last_time + period) > 0)
  # Send alert
  NotifyMailer.notify_email(alert).deliver
  # but do not let Procmail forward a copy
  exit 1
else
  exit 1
end
  
