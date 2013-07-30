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

# Parse the email
while (line = gets)
  if line =~ /^Device Name: (.+)/i
    name = $1
  elsif line =~ /^Device Model: (.+)$/i
    model = $1
  elsif line =~ /^Serial Number: (\S+)/i
    serial = $1
  elsif line =~ /^Machine Code: (.+)/i
    code = $1
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
  elsif line =~ /^Toner Residual \(Bk\).*\s(.+)/
    tonerleftbk = $1
  elsif line =~ /^Toner Residual \(C\).*\s(.+)/
    tonerleftc = $1
  elsif line =~ /^Toner Residual \(M\).*\s(.+)/
    tonerleftm = $1
  elsif line =~ /^Toner Residual \(Y\).*\s(.+)/
    tonerlefty = $1
  elsif line =~ /^Copy Count.*\s(\d+)/
    copybw = $1
  elsif line =~ /^Print Count.*\s(\d+)/
    printbw = $1
  elsif line =~ /^Total Count.*\s(\d+)/
    totalprintbw = $1
  elsif line =~ /^From:\s*(.+)/
    from = $1
  elsif line =~ /^.+ = .+/
    puts "Unrecognized line: [#{line}]"
  end
end
dev = Device.where(["model = ? and serial = ?", model, serial]).first
if dev.nil?
  dev = Device.create(:name => name, :model => model, :serial => serial, :code => code)
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
  NotifyMailer.nopv_email(dev).deliver
  exit 1
end

@first = Counter.earliest_or_before(@last.status_date.months_ago(1).to_date, dev.id)
unless @first.nil?
  NotifyMailer.counter_alert(@first, @last).deliver
end