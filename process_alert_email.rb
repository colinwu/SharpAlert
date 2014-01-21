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

# Parse the Jam Trouble attachment file in directory dir for the jam code.
def getJamCode(dir)
  f = File.open(dir + '/E-mail DIAG Jam Trouble Data.R05')
  jamcode = 'unknown'
  
  title = f.read(15)
  if (title == 'JAM TROUBLE HIS')
    f.read(35)
    # read and convert send date and time
    yr = "%02x" % f.read(1).ord
    mon = "%02x" % f.read(1).ord
    day = "%02x" % f.read(1).ord
    hr = "%02x" % f.read(1).ord
    min = "%02x" % f.read(1).ord
    sec = "%02x" % f.read(1).ord
    sentdate = yr + mon + day + hr + min
    puts "Sent date: #{sentdate}"
    f.read(1)
    dfcount = f.read(1).ord
    # start of first DF history record - most recent first
    f.read(1)
    if (dfcount != 0)
      jamcode = '%02x' % f.read(1).ord
      yr = "%02x" % f.read(1).ord
      mon = "%02x" % f.read(1).ord
      day = "%02x" % f.read(1).ord
      hr = "%02x" % f.read(1).ord
      min = "%02x" % f.read(1).ord
      sec = "%02x" % f.read(1).ord
      recdate = yr + mon + day + hr + min
      f.read(12)               # skip over the rest of this record
      f.read(20 * (dfcount-1)) # skip over all remaining records
      #       puts "First DF/MB record date: #{recdate}"
    end
    if (sentdate == recdate)
      return jamcode
    else
      # skip over the MB count - we don't care since we're only interested
      # in the first record
      f.read(2) 
      f.read(1)
      jamcode = '%02x' % f.read(1).ord
      yr = "%02x" % f.read(1).ord
      mon = "%02x" % f.read(1).ord
      day = "%02x" % f.read(1).ord
      hr = "%02x" % f.read(1).ord
      min = "%02x" % f.read(1).ord
      sec = "%02x" % f.read(1).ord
      recdate = yr + mon + day + hr + min
      #       puts "First MB record date: #{recdate}"
      if (sentdate == recdate)
        return jamcode
      end
    end
  end
end

require 'getopt/std'

opt = Getopt::Std.getopts('d:')
if opt['d']
  dir = opt['d']
#   puts "Directory specified. Read input from file."
#   if File.exist?(dir + '/textfile1')
#     f = File.open(dir + '/textfile1')
#   elsif File.exist?(dir + '/textfile0')
#     f = File.open(dir + '/textfile0')
#   else
#     f = $stdin
#   end
end

f = $stdin


alert = Alert.new

# Parse the alert message
while (line = f.gets)
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
      codes = f.gets.strip
      msg += ": #{codes}"
    elsif msg =~ /Maintenance required. Code:(.+)$/
      codes = $1
    elsif msg =~ /Misfeed/i
      jamcode = getJamCode(dir)
      unless jamcode.nil?
        msg += " (Jam code 0x#{jamcode})"
      end
    end
    alert.alert_msg = msg
  elsif line =~ /^(\d{4,4}\/\d{2,2}\/\d{2,2}\s+\d{2,2}:\d{2,2}:\d{2,2})/
    alert.alert_date = $1
  elsif line =~ /^From: (.+)/
    from = $1
  end
  
#   next if name.nil? or model.nil? or serial.nil? or code.nil? or msg.nil? or from.nil? or alert.alert_date.nil?
  
end

# retrieve details of the last alert for this device before committing this alert
alert.save

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

# TODO: Uncomment the following before deploying
system("/bin/rm -r #{dir}")

if not send_to.nil? and not period.nil? and (last_time.nil? or (alert.alert_date <=> last_time + period) > 0)
  # Send alert
  NotifyMailer.notify_email(alert).deliver
#   exit 1
else
  exit 1
end
