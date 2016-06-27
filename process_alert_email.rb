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

model = nil
serial = ''
name = nil
code = nil
boundary = nil
dev_ip = nil

code_list = Array.new
# Suck in the entire input (hopefully it's not too much)
rawdata = Array.new
rawdata = f.readlines
rawdata.reverse!

# Parse the alert message
while (rawdata.length > 0)
  line = rawdata.pop
  line.rstrip!
  if (line =~ /^Device Name: (.+)/i or line =~ /^Nom du périphérique: (.+)/i)
    name = $1
  elsif (line =~ /^Device Model: (.+)/i or line =~ /^Modèle de périphérique: (.+)/i)
    model = $1
  elsif (line =~ /^Serial Number: (\S+)/i or line =~ /^Numéro de Série: (\S+)/i)
    serial = $1
  elsif (line =~ /^Machine Code: (.+)/i or line =~ /^Code de la machine: (.+)/i)
    code = $1
  elsif line =~ /^!!!!! (.+) !!!!!/
    msg = $1
    if (msg =~ /Call for service/)
      codes = rawdata.pop.strip
      msg = "Call for service: #{codes}"
      code_list = codes.split
    elsif (msg =~ /Maintenance required. Code:(.+)/ or msg =~ /Intervention technicien requise. Code:(.+)/)
      codes = $1
      msg = "Maintenance required. Code:#{codes}"
      code_list = codes.split
    elsif msg =~ /toner.+\( (\S+) \)/i
      code_list = $1.split('/')
    end
    alert_msg = msg
  elsif line =~ /^(\d{4,4}\/\d{2,2}\/\d{2,2}\s+\d{2,2}:\d{2,2}:\d{2,2})/
    alert_date = $1
  elsif line =~ /^From: (.+)/
    from = $1
    from =~ /@(.+)>/
    from_domain = $1
  elsif line =~ /^Received: from /
    while (tmp = rawdata.pop)
      if (tmp =~ /^\s+/)
        tmp.strip!
        line += tmp
      else
        rawdata.push(tmp)
        break
      end
    end
    line =~ /^Received: from.+[\(\[](\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})[\)\]]+\s+by/
    dev_ip = $1
    puts "IP: #{dev_ip}"
  elsif line =~ /^--SmTP-MULTIPART-BOUNDARY/
    if (boundary.nil?)
      boundary = 1
    else
      break
    end
  end
end

if serial.nil? or serial.empty? # ignore the alert if there is no serial number
  exit
end

if name.nil? or name.empty?
  name = dev_ip
end

# ignore Load Paper messages that are more than a day old
if alert_msg =~ /Load Paper/i and (Time.parse(alert_date) < (Time.now - 86400))
  exit
end

# Check if this alert already exists (in case we're processing old alerts)
@d = Device.find_by_serial_and_model(serial,model)
unless @d.nil?
  # if the device does not exist (in the db) don't bother checking for old alert
  alert = Alert.where("alert_date = '#{alert_date}' and (alert_msg = '#{alert_msg}' or alert_msg regexp 'Misfeed') and device_id = #{@d.id}").order(:alert_date).last
end

if alert.nil?
  # No old alert exists that matches this one so create a new one
  alert = Alert.new
  alert.alert_date = alert_date
  alert.alert_msg = alert_msg
  alert.save
end

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
    if (MaintCode.where(["alert_id = ? and code = ?", alert.id, c]).empty?)
      alert.maint_codes.create(:code => c)
    end
  end
elsif (alert_msg =~ /Service/i)
  code_list.each do |c|
    if (ServiceCode.where(["alert_id = ? and code = ?", alert.id, c]).empty?)
      alert.service_codes.create(:code => c)
    end
  end
elsif (alert_msg =~ /toner.+\( \S+ \)/i)
  code_list.each do |c|
    if (TonerCode.where(["alert_id = ? and colour = ?", alert.id, c]).empty?)
      alert.toner_codes.create(:colour => c)
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
    :code => code,
    :ip => dev_ip)
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
  client = Client.find_by_pattern(from_domain)
  if client.nil?
    NotifyMailer.new_device('wuc@sharpsec.com,torica@sharpsec.com',@d,from).deliver
  else
    @d.client_id = client.id
    NotifyMailer.new_device_warn('wuc@sharpsec.com,torica@sharpsec.com',@d,from).deliver
  end
  @d.save
else
  alert.device_id = @d.id
  # keep device name updated - just in case the client changes it.
  @d.update_attributes(:name => name, :ip => dev_ip)
  @d.save
  @n = @d.notify_control
end
alert.save

# figure out if we need to send notification (ignore if alert is more than a day old)
if ((Time.now - alert.alert_date) < 86400)
  
  NotifyMailer.notify_email(alert).deliver
  
#   if alert.alert_msg =~ /Misfeed/ and not @n.jam.nil?
#     period = @n.jam * 3600
#     last_time = @n.jam_sent
#     send_to = @n.local_admin.empty? ? 'wuc@sharpsec.com' : [@n.local_admin,'wuc@sharpsec.com'].join(',')
#   elsif alert.alert_msg =~ /Add toner/ and not @n.toner_empty.nil?
#     period = @n.toner_empty * 3600
#     last_time = @n.toner_empty_sent
#     send_to = @n.local_admin.empty? ? 'wuc@sharpsec.com' : [@n.local_admin,'wuc@sharpsec.com'].join(',')
#   elsif alert.alert_msg =~ /Toner supply/i and not @n.toner_low.nil?
#     period = @n.toner_low * 3600
#     last_time = @n.toner_low_sent
#     send_to = @n.local_admin.empty? ? 'wuc@sharpsec.com' : [@n.local_admin,'wuc@sharpsec.com'].join(',')
#   elsif alert.alert_msg =~ /Load paper/ and not @n.paper.nil?
#     period = @n.paper * 3600
#     last_time = @n.paper_sent
#     send_to = @n.local_admin
#   elsif alert.alert_msg =~ /Call for service/ and not @n.service.nil?
#     period = @n.service * 3600
#     last_time = @n.service_sent
#     send_to = @n.tech
#   elsif alert.alert_msg =~ /Maintenance required/ and not @n.pm.nil?
#     period = @n.pm * 3600
#     last_time = @n.pm_sent
#     send_to = @n.tech.empty? ? 'wuc@sharpsec.com' : [@n.tech,'wuc@sharpsec.com'].join(',')
#   elsif alert.alert_msg =~ /Replace used toner/ and not @n.waste_full.nil?
#     period = @n.waste_full * 3600
#     last_time = @n.waste_full_sent
#     send_to = @n.local_admin
#   elsif alert.alert_msg =~ /Replacement the toner/ and not @n.waste_almost_full.nil?
#     period = @n.waste_almost_full * 3600
#     last_time = @n.waste_almost_full_sent
#     send_to = @n.local_admin
#   elsif alert.alert_msg =~ /Job/ and not @n.job_log_full.nil?
#     period = @n.job_log_full * 3600
#     last_time = @n.job_log_full_sent
#     send_to = nil
#   else
#     period = nil
#     send_to = nil
#   end
#   
#   # TODO: Uncomment the following before deploying
#   # system("/bin/rm -r #{dir}")
#   
#   if not send_to.nil? and not period.nil? and (last_time.nil? or (alert.alert_date <=> last_time + period) > 0)
#     # Send alert
#     NotifyMailer.notify_email(send_to, alert).deliver
#   #   exit 1
#   end
end
