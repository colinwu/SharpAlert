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
  # returns JamStat record id or nil if no matching history found
  unless (!dir.nil? and File.exists?(dir + '/E-mail DIAG Jam Trouble Data.R05'))
    return nil
  end
  
  f = File.open(dir + '/E-mail DIAG Jam Trouble Data.R05')
  
  title = f.read(15)
  if (title == 'JAM TROUBLE HIS')
    js = JamStat.new()
    f.read(35)
    # read and convert send date and time
    yr = "%02x" % f.read(1).ord
    mon = "%02x" % f.read(1).ord
    day = "%02x" % f.read(1).ord
    hr = "%02x" % f.read(1).ord
    min = "%02x" % f.read(1).ord
    sec = "%02x" % f.read(1).ord
    sentdate = yr + mon + day + hr + min

    dfcount = f.read(2).unpack('S>')[0]
    # start of first DF history record - most recent first
    f.read(1)
    if (dfcount > 0)
      jamcode = '%02x' % f.read(1).ord
      yr = "%02x" % f.read(1).ord
      mon = "%02x" % f.read(1).ord
      day = "%02x" % f.read(1).ord
      hr = "%02x" % f.read(1).ord
      min = "%02x" % f.read(1).ord
      sec = "%02x" % f.read(1).ord
      recdate = yr + mon + day + hr + min
      paper_code = "%02x" % f.read(1).ord
      paper_type = "%02x" % f.read(1).ord
      f.read(2) # skip over the 0xffff
      sheet_count_bw = f.read(4).unpack('L>')[0]
      sheet_count_colour = f.read(4).unpack('L>')[0]
      
      f.read(20 * (dfcount-1)) # skip over all remaining records
      #       puts "First DF/MB record date: #{recdate}"
    end
    if (sentdate == recdate)
      js.jam_code = jamcode
      js.paper_type = paper_type
      js.paper_code = paper_code
      js.jam_type = 'DF'
      js.save
      f.close
      return js
    else
      # see if there is a matching MB jam history
      mbcount = f.read(2).unpack('S>')[0]
      if (mbcount > 0)
        f.read(1)
        jamcode = '%02x' % f.read(1).ord
        yr = "%02x" % f.read(1).ord
        mon = "%02x" % f.read(1).ord
        day = "%02x" % f.read(1).ord
        hr = "%02x" % f.read(1).ord
        min = "%02x" % f.read(1).ord
        sec = "%02x" % f.read(1).ord
        recdate = yr + mon + day + hr + min
        
        paper_code = "%02x" % f.read(1).ord
        paper_type = "%02x" % f.read(1).ord
        f.read(2) # skip over the 0xffff
        sheet_count_bw = f.read(4).unpack('L>')[0]
        sheet_count_colour = f.read(4).unpack('L>')[0]
      end
      if (sentdate == recdate)
        js.jam_code = jamcode
        js.paper_type = paper_type
        js.paper_code = paper_code
        js.jam_type = 'DF'
        js.save
        f.close
        return js
      else
        f.close
        return nil
      end
    end
  else
    f.close
    return nil
  end
end

def getSheetCount(dir)
  # returns SheetCount record id or nil if error or none found
  unless (!dir.nil? and File.exists?(dir + '/E-mail DIAG Job Counter Data.R08'))
    return nil
  end
  f = File.open(dir + '/E-mail DIAG Job Counter Data.R08')
  title = f.read(16)
  if (title == 'JOB COUNTER DATA')
    sc = SheetCount.new()
    f.read(216)
    (sc.bw, sc.color) = f.read(8).unpack('L>L>')
    sc.save
    f.close
    return sc
  else
    f.close
    return nil
  end
end

def getMaintCounter(dir)
  # returns MaintCounter record id or nil if error or none found
  unless (!dir.nil? and File.exists?(dir + '/E-mail DIAG Maintenance Counter Data.R09'))
    return nil
  end
  f = File.open(dir + '/E-mail DIAG Maintenance Counter Data.R09')
  title = f.read(15)
  if (title == 'MAINTE CNT DATA')
    mc = MaintCounter.new
    f.read(45)
    (mc.maint_total,mc.maint_color) = f.read(8).unpack('L>L>')
    (mc.drum_print_b,mc.drum_print_c,mc.drum_print_m,mc.drum_print_y) =
        f.read(16).unpack('L>' * 4)
    (mc.dev_print_b,mc.dev_print_c,mc.dev_print_m,mc.dev_print_y) =
        f.read(16).unpack('L>' * 4)
    f.read(16)
    (mc.drum_dist_b,mc.drum_dist_c,mc.drum_dist_m,mc.drum_dist_y) =
        f.read(16).unpack('L>' * 4)
    (mc.dev_dist_b,mc.dev_dist_c,mc.dev_dist_m,mc.dev_dist_y) =
        f.read(16).unpack('L>' * 4)
    f.read(16)
    (mc.scan,mc.spf_count) = f.read(8).unpack('L>L>')
    f.read(60)
    (mc.ptu_print,mc.ptu_dist) = f.read(8).unpack('L>L>')
    f.read(4)
    (mc.stu_print,mc.stu_dist,mc.stu_days) = f.read(12).unpack('L>' * 3)
    (mc.fusing_print,mc.fusing_days,mc.fusing_web_clean) = f.read(12).unpack('L>' * 3)
    f.read(16)
    (mc.toner_motor_b,mc.toner_motor_c,mc.toner_motor_m,mc.toner_motor_y) =
        f.read(16).unpack('L>' * 4)
    (mc.drum_rotation_b,mc.drum_rotation_c,mc.drum_rotation_m,mc.drum_rotation_y) =
        f.read(16).unpack('L>' * 4)
    (mc.dev_rotation_b,mc.dev_rotation_c,mc.dev_rotation_m,mc.dev_rotation_y) =
        f.read(16).unpack('L>' * 4)
    mc.save
    f.close
    return mc
  else
    f.close
    return nil
  end
end

require 'getopt/std'

opt = Getopt::Std.getopts('d:')
if opt['d']
  dir = opt['d']
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
      sc = getSheetCount(dir)
      mc = getMaintCounter(dir)
    elsif msg =~ /Maintenance required. Code:(.+)$/
      codes = $1
      sc = getSheetCount(dir)
      mc = getMaintCounter(dir)
    elsif msg =~ /Misfeed/i
      js = getJamCode(dir)
      unless js.nil?
        msg += " (Jam code #{js.jam_code})"
      end
      sc = getSheetCount(dir)
      mc = getMaintCounter(dir)
    elsif msg =~ /toner/i
      sc = getSheetCount(dir)
      mc = getMaintCounter(dir)
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
unless mc.nil?
  mc.alert_id = alert.id
  mc.save
end
unless sc.nil?
  sc.alert_id = alert.id
  sc.save
end
unless js.nil?
  js.alert_id = alert.id
  js.save
end

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
