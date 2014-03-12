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
    if (dfcount > 0)
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
        js.jam_type = 'MB'
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
    # at 0x003C
    (mc.maint_total,mc.maint_color) = f.read(8).unpack('L>L>')
    # 0x0044
    (mc.drum_print_b,mc.drum_print_c,mc.drum_print_m,mc.drum_print_y) =
        f.read(16).unpack('L>' * 4)
    (mc.dev_print_b,mc.dev_print_c,mc.dev_print_m,mc.dev_print_y) =
        f.read(16).unpack('L>' * 4)
    f.read(16)
    # 0x0074
    (mc.drum_dist_b,mc.drum_dist_c,mc.drum_dist_m,mc.drum_dist_y) =
        f.read(16).unpack('L>' * 4)
    (mc.dev_dist_b,mc.dev_dist_c,mc.dev_dist_m,mc.dev_dist_y) =
        f.read(16).unpack('L>' * 4)
    f.read(16)
    # 0x00A4
    (mc.scan,mc.spf_count) = f.read(8).unpack('L>L>')
    f.read(44)
    # 0x00D8
    mc.mft_total = f.read(4).unpack('L>')[0]
    (mc.tray1,mc.tray2,mc.tray3,mc.tray4) = f.read(16).unpack('L>' * 4)
    f.read(8)
    mc.adu = f.read(4).unpack('L>')[0]
    (mc.ptu_print,mc.ptu_dist,mc.ptu_days) = f.read(12).unpack('L>' * 3)
    (mc.stu_print,mc.stu_dist,mc.stu_days) = f.read(12).unpack('L>' * 3)
    (mc.fuser_print,mc.fuser_days) = f.read(8).unpack('L>' * 2)
    f.read(4)
    (mc.toner_motor_b,mc.toner_motor_c,mc.toner_motor_m,mc.toner_motor_y) =
        f.read(16).unpack('L>' * 4)
    (mc.toner_rotation_b,mc.toner_rotation_c,mc.toner_rotation_m,mc.toner_rotation_y) =
        f.read(16).unpack('L>' * 4)
    (mc.drum_life_used_b,mc.drum_life_used_c,mc.drum_life_used_m,mc.drum_life_used_y) =
        f.read(16).unpack('L>' * 4)
    (mc.dev_life_used_b,mc.dev_life_used_c,mc.dev_life_used_m,mc.dev_life_used_y) =
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

code_list = Array.new
# Parse the alert message
while (line = f.gets)
  if line =~ /^Device Name: (.+)/i
    name = $1
  elsif line =~ /^Device Model: (.+)/i
    model = $1
  elsif line =~ /^Serial Number: (\S+)/i
    serial = $1
    if serial.empty? # ignore the alert if there is no serial number
      exit
    end
  elsif line =~ /^Machine Code: (.+)/i
    code = $1
  elsif line =~ /^!!!!! (.+) !!!!!/
    msg = $1
    if msg =~ /Call for service/
      codes = f.gets.strip
      msg += ": #{codes}"
      code_list = codes.split
    elsif msg =~ /Maintenance required. Code:(.+)$/
      codes = $1
      code_list = codes.split
    elsif msg =~ /toner.+\( (\S+) \)/i
      code_list = $1.split
    end
    alert_msg = msg
  elsif line =~ /^(\d{4,4}\/\d{2,2}\/\d{2,2}\s+\d{2,2}:\d{2,2}:\d{2,2})/
    alert_date = $1
  elsif line =~ /^From: (.+)/
    from = $1
  end
end

# Check if this alert already exists (in case we're processing old alerts)
@d = Device.find_by_serial_and_model(serial,model)
unless @d.nil?
  # if the device does not exist (in the db) don't bother checking for old alert
  alert = Alert.where("alert_date = '#{alert_date}' and (alert_msg = '#{alert_msg}' or alert_msg regexp 'Misfeed') and device_id = #{@d.id}").first
end

if alert.nil?
  # No old alert exists that matches this one so create a new one
  alert = Alert.new
  alert.alert_date = alert_date
  alert.alert_msg = alert_msg
  alert.save
end


unless (alert_msg =~ /paper/i or alert_msg =~ /Job Log/i) 
  # ignore "Load Paper" and "job log full" alerts, also make sure there are no 
  # SheetCount, MaintCounter and JamStat records already
  if (alert.sheet_count.nil?)
    sc = getSheetCount(dir)
    unless sc.nil?
      sc.alert_id = alert.id
      sc.save
    end
  end
  if (alert.maint_counter.nil?)
    mc = getMaintCounter(dir)
    unless mc.nil?
      mc.alert_id = alert.id
      mc.save
    end
  end
  if (alert_msg =~ /Misfeed/i and alert.jam_stat.nil?)
    js = getJamCode(dir)
    unless js.nil?
      js.alert_id = alert.id
      js.save
    end
  elsif (alert_msg =~ /Maintenance/i)
    code_list.each do |c|
      if (alert.maint_codes.empty?)
        alert.maint_codes.create(:code => c)
      end
    end
  elsif (alert_msg =~ /Service/i)
    puts "Alert ID: #{alert.id}"
    puts code_list.inspect
    code_list.each do |c|
      if (alert.service_codes.empty?)
        puts "Service Code: #{c}"
        alert.service_codes.create(:code => c)
      end
    end
  elsif (alert_msg =~ /toner.+\( \S+ \)/i)
    code_list.each do |c|
      if (alert.toner_codes.empty?)
        alert.toner_codes.create(:colour => c)
      end
    end
  end
end

# retrieve (or create using defaults) the notification profile for this device.
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
  # keep device name updated - just in case the client changes it.
  @d.update_attribute('name', name)
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
# system("/bin/rm -r #{dir}")

if not send_to.nil? and not period.nil? and (last_time.nil? or (alert.alert_date <=> last_time + period) > 0)
  # Send alert
  NotifyMailer.notify_email(alert).deliver
#   exit 1
else
  exit 1
end
