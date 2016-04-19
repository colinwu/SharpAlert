# Parses a Sharp MFP status email and records it as an Alert object. This program should be
# invoked by one of Procmail's filter rules.
#
# The email has the following form for a colour machine. B&W machines will not have the color
# (sic) fields.
#
# 2013/06/06 07:10:04
# 
# Device Name:
# Device Model: MX-5111N
# 
# Serial Number: 1504775700
# Machine Code:
# 
# Current Device Counter Information:
# 
# Black & White Copy Count = 510
# Two Color Copy Count = 0
# Single Color Copy Count = 2832
# Full Color Copy Count = 78
# 
# Black & White Print Count = 141
# Full Color Print Count = 18369
# 
# Black & White Total Print Count = 1015
# Two Color Total Print Count = 0
# Single Color Total Print Count = 2832
# Color Total Print Count = 18480
# 
# Black & White Scanner Count = 885
# Two Color Scanner Count = 0
# Single Color Scanner Count = 0
# Full Color Scanner Count = 6
# 
# 
# Black & White Document Filing Print Count = 0
# Two Color Document Filing Print Count = 0
# Single Color Document Filing Count = 0
# Full Color Document Filing Print Count = 0
# 
# I-Fax Receive Count = 0
# Fax Receive Line1  = 3
# Fax Receive Line2 = 0
# Fax Receive Line3 = 0
# 
# Black & White Other Print Count = 361
# Color Other Print Count = 33
# 
# I-Fax Send Count = 0
# Fax Send Line1 = 45
# Fax Send Line2 = 0
# Fax Send Line3 = 0
# 
# Black & White Scan to HDD Count = 9
# Two Color Scan to HDD Count = 0
# Single Color Scan to HDD Count = 0
# Full Color Scan to HDD Count = 11
# 
# 
# Inserted Toner Number (Bk) = 0
# Inserted Toner Number (C) = 0
# Inserted Toner Number (M) = 0
# Inserted Toner Number (Y) = 0
# 
# 
# Toner NN End (Bk) = 0
# Toner NN End (C) = 1
# Toner NN End (M) = 0
# Toner NN End (Y) = 2
# 
# 
# Toner End (Bk) = 0
# Toner End (C) = 1
# Toner End (M) = 3
# Toner End (Y) = 0
# 
# 
# Toner Residual (Bk) = 25-50%
# Toner Residual (C) = 0-25%
# Toner Residual (M) = 75-100%
# Toner Residual (Y) = 75-100%

def getMaintCounter(dir)
  # returns MaintCounter record id or nil if error or none found
  unless (!dir.nil? and File.exists?(dir + '/E-mail DIAG Maintenance Counter Data.R09'))
    puts "Could not find maintenance data file"
    return nil
  end
  f = File.open(dir + '/E-mail DIAG Maintenance Counter Data.R09')
  title = f.read(15)
  puts title
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
#    mc.save
    f.close
    return mc
  else
    f.close
    return nil
  end
end

############ End of function defs #############

require 'getopt/std'

opt = Getopt::Std.getopts('d:')
if opt['d']
  dir = opt['d']
  puts dir
end

f = $stdin


# Parse the email
while (line = f.gets)
  if line =~ /^Device Name: (.+)/i
    name = $1.strip
  elsif line =~ /^Device Model: (.+)/i
    model = $1.strip
  elsif line =~ /^Serial Number: (\S+)/i
    serial = $1
  elsif line =~ /^Machine Code: (.+)/i
    code = $1.strip
  elsif line =~ /^(\d{4,4}\/\d{2,2}\/\d{2,2}\s+\d{2,2}:\d{2,2}:\d{2,2})/
    status_date = $1
  elsif line =~ /^Black & White Copy Count.*\s(\d+)/
    copybw = $1
  elsif line =~ /^Two Color Copy Count.*\s(\d+)/
    copy2c = $1
  elsif line =~ /^Single Color Copy Count.*\s(\d+)/
    copy1c = $1
  elsif line =~ /^Full Color Copy Count.*\s(\d+)/
    copyfc = $1
  elsif line =~ /^Black & White Print Count.*\s(\d+)/
    printbw = $1
  elsif line =~ /^Full Color Print Count.*\s(\d+)/
    printfc = $1
  elsif line =~ /^Black & White Total Print Count.*\s(\d+)/
    totalprintbw = $1
  elsif line =~ /^Two Color Total Print Count.*\s(\d+)/
    totalprint2c = $1
  elsif line =~ /^Single Color Total Print Count.*\s(\d+)/
    totalprint1c = $1
  elsif line =~ /^Color Total Print Count.*\s(\d+)/
    totalprintc = $1
  elsif line =~ /^Black & White Scanner Count.*\s(\d+)/
    scanbw = $1
  elsif line =~ /^Two Color Scanner Count.*\s(\d+)/
    scan2c = $1
  elsif line =~ /^Single Color Scanner Count.*\s(\d+)/
    scan1c = $1
  elsif line =~ /^Full Color Scanner Count.*\s(\d+)/
    scanfc = $1
  elsif line =~ /^Black & White Document Filing Print Count.*\s(\d+)/
    fileprintbw = $1
  elsif line =~ /^Two Color Document Filing Print Count.*\s(\d+)/
    fileprint2c = $1
  elsif line =~ /^Single Color Document Filing Count.*\s(\d+)/
    fileprint1c = $1
  elsif line =~ /^Full Color Document Filing Print Count.*\s(\d+)/
    fileprintfc = $1
  elsif line =~ /^I-Fax Receive Count.*\s(\d+)/
    faxin = $1
  elsif line =~ /^Fax Receive Line1 .*\s(\d+)/
    faxinline1 = $1
  elsif line =~ /^Fax Receive Line2.*\s(\d+)/
    faxinline2 = $1
  elsif line =~ /^Fax Receive Line3.*\s(\d+)/
    faxinline3 = $1
  elsif line =~ /^Black & White Other Print Count.*\s(\d+)/
    otherprintbw = $1
  elsif line =~ /^Color Other Print Count.*\s(\d+)/
    otherprintc = $1
  elsif line =~ /^I-Fax Send Count.*\s(\d+)/
    faxout = $1
  elsif line =~ /^Fax Send Line1.*\s(\d+)/
    faxoutline1 = $1
  elsif line =~ /^Fax Send Line2.*\s(\d+)/
    faxoutline2 = $1
  elsif line =~ /^Fax Send Line3.*\s(\d+)/
    faxoutline3 = $1
  elsif line =~ /^Black & White Scan to HDD Count.*\s(\d+)/
    hddscanbw = $1
  elsif line =~ /^Two Color Scan to HDD Count.*\s(\d+)/
    hddscan2c = $1
  elsif line =~ /^Single Color Scan to HDD Count.*\s(\d+)/
    hddscan1c = $1
  elsif line =~ /^Full Color Scan to HDD Count.*\s(\d+)/
    hddscanfc = $1
  elsif line =~ /^Inserted Toner Number \(Bk\).*\s(\d+)/
    tonerbkin = $1
  elsif line =~ /^Inserted Toner Number \(C\).*\s(\d+)/
    tonercin = $1
  elsif line =~ /^Inserted Toner Number \(M\).*\s(\d+)/
    tonermin = $1
  elsif line =~ /^Inserted Toner Number \(Y\).*\s(\d+)/
    toneryin = $1
  elsif line =~ /^Toner NN End \(Bk\).*\s(\d+)/
    tonernnendbk = $1
  elsif line =~ /^Toner NN End \(C\).*\s(\d+)/
    tonernnendc = $1
  elsif line =~ /^Toner NN End \(M\).*\s(\d+)/
    tonernnendm = $1
  elsif line =~ /^Toner NN End \(Y\).*\s(\d+)/
    tonernnendy = $1
  elsif line =~ /^Toner End \(Bk\).*\s(\d+)/
    tonerendbk = $1
  elsif line =~ /^Toner End \(C\).*\s(\d+)/
    tonerendc = $1
  elsif line =~ /^Toner End \(M\).*\s(\d+)/
    tonerendm = $1
  elsif line =~ /^Toner End \(Y\).*\s(\d+)/
    tonerendy = $1
  elsif line =~ /^Toner Residual \(Bk\).*\s(.+%)/
    tonerleftbk = $1
  elsif line =~ /^Toner Residual \(C\).*\s(.+%)/
    tonerleftc = $1
  elsif line =~ /^Toner Residual \(M\).*\s(.+%)/
    tonerleftm = $1
  elsif line =~ /^Toner Residual \(Y\).*\s(.+%)/
    tonerlefty = $1
  elsif line =~ /^Copy Count.*\s(\d+)/
    copybw = $1
  elsif line =~ /^Print Count.*\s(\d+)/
    printbw = $1
  elsif line =~ /^Total Count.*\s(\d+)/
    totalprintbw = $1
  elsif line =~ /^From:\s*(.+)/
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
  elsif line =~ /^--SmTP-MULTIPART-BOUNDARY/
    if (boundary.nil?)
      boundary = 1
    else
      break
    end
  end
elsif line =~ /^.+ = .+/
    puts "Unrecognized line: [#{line}]"
  end
end
dev = Device.where(["model = ? and serial = ?", model, serial]).first
if dev.nil?
  client = Client.find_by_pattern(from_domain)
  if client.nil?
    c_id = nil
  else
    c_id = client.id
  end
  dev = Device.create(:name => name, :model => model, :serial => serial, :code => code, :dev_ip => dev_ip, :client_id => c_id)
  ndef = NotifyControl.joins(:device).where("devices.serial = 'default'").first
  nc = dev.create_notify_control(:tech => ndef.tech, :local_admin => ndef.local_admin, :jam => ndef.jam, :toner_low => ndef.toner_low, :toner_empty => ndef.toner_empty, :paper => ndef.paper, :service => ndef.service, :pm => ndef.pm, :waste_almost_full => ndef.waste_almost_full, :waste_full => ndef.waste_full, :job_log_full => ndef.job_log_full)
  NotifyMailer.new_device('wuc@sharpsec.com',dev,from).deliver
end

@last = dev.counters.create(
  :status_date => status_date,
  :copybw => copybw, 
  :copy2c => copy2c,
  :copy1c => copy1c,
  :copyfc => copyfc,
  :printbw => printbw,
  :printfc => printfc,
  :totalprintbw => totalprintbw,
  :totalprint2c => totalprint2c,
  :totalprint1c => totalprint1c,
  :totalprintc => totalprintc,
  :scanbw => scanbw,
  :scan2c => scan2c,
  :scan1c => scan1c,
  :scanfc => scanfc,
  :fileprintbw => fileprintbw,
  :fileprint2c => fileprint2c,
  :fileprint1c => fileprint1c,
  :fileprintfc => fileprintfc,
  :faxin => faxin,
  :faxinline1 => faxinline1,
  :faxinline3 => faxinline3,
  :otherprintbw => otherprintbw,
  :otherprintc => otherprintc,
  :faxout => faxout,
  :faxoutline1 => faxoutline1,
  :faxoutline2 => faxoutline2,
  :faxoutline3 => faxoutline3,
  :hddscanbw => hddscanbw,
  :hddscan2c => hddscan2c,
  :hddscan1c => hddscan1c,
  :hddscanfc => hddscanfc,
  :tonerbkin => tonerbkin,
  :tonercin => tonercin,
  :tonermin => tonermin,
  :toneryin => toneryin,
  :tonernnendbk => tonernnendbk,
  :tonernnendc => tonernnendc,
  :tonernnendm => tonernnendm,
  :tonernnendy => tonernnendy,
  :tonerendbk => tonerendbk,
  :tonerendc => tonerendc,
  :tonerendm => tonerendm,
  :tonerendy => tonerendy,
  :tonerleftbk => Counter.reslevel[tonerleftbk],
  :tonerleftc => Counter.reslevel[tonerleftc],
  :tonerleftm => Counter.reslevel[tonerleftm],
  :tonerlefty => Counter.reslevel[tonerlefty]
)

# Check if we have print volume data for this device
if dev.print_volume.nil?
#  NotifyMailer.nopv_email(dev).deliver
#  exit 1
end

# Send a usage alert message if the ratio is either negative or above 150%

# @first = Counter.earliest_or_before(@last.status_date.months_ago(1).to_date, dev.id)
# unless @first.nil?
#   NotifyMailer.counter_alert(@first, @last).deliver
# end

mc = getMaintCounter(dir)
unless mc.nil?
  # print out .csv
  mcout = File.open('/tmp/mc.csv', 'a')
  fsize = File.size?('/tmp/mc.csv')
  if fsize.nil? or fsize == 0 # if nothing in the output file yet output column header
    mcout.puts '"Timestamp","Model","Serial #","Maint Total","Maint Color","Drum Print B","Drum Print C","Drum Print M","Drum Print Y","Dev Print B","Dev Print C","Dev Print M","Dev Print Y","Drum Dist B","Drum Dist C","Drum Dist M","Drum Dist Y","Dev Dist B","Dev Dist C","Dev Dist M","Dev Dist Y","Drum Life B","Drum Life C","Drum Life M","Drum Life Y","Dev Life B","Dev Life C","Dev Life M","Dev Life Y","Scan","SPF Count","PTU Print","PTU Dist","PTU Days","ADU","STU Print","STU Dist","STU Days","Fuser Print","Fuser Days","Toner Motor Bk","Toner Motor C","Toner Motor M","Toner Motor Y","Toner Rotation Bk","Toner Rotation C","Toner Rotation M","Toner Rotation Y","MFT Total","Tray 1","Tray 2","Tray 3","Tray 4"'
  end
  mcout.puts '"' + status_date + '","' + model + '","' + serial + '",' + mc.to_csv
  mcout.close
end
#system("/bin/rm -r #{dir}")
