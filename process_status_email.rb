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

status = Status.new

# Parse the email
while (line = gets)
  if line =~ /^Device Name: (.+)/
    name = $1
  elsif line =~ /^Device Model: (\S+)/
    model = $1
  elsif line =~ /^Serial Number: (\S+)/
    serial = $1
  elsif line =~ /^Machine Code: (\S+)/
    code = $1
  elsif line =~ /^(\d{4,4}\/\d{2,2}\/\d{2,2}\s+\d{2,2}:\d{2,2}:\d{2,2})/
    status.sent_date = $1
  elsif line =~ /^Black & White Copy Count = (\d+)/
    copybw = $1
  elsif line =~ /^Two Color Copy Count = (\d+)/
    copy2c = $1
  elsif line =~ /^Single Color Copy Count = (\d+)/
    copy1c = $1
  elsif line =~ /^Full Color Copy Count = (\d+)/
    copyfc = $1
  elsif line =~ /^Black & White Print Count = (\d+)/
    printbw = $1
  elsif line =~ /^Full Color Print Count = (\d+)/
    printfc = $1
  elsif line =~ /^Black & White Total Print Count = (\d+)/
    totalprintbw = $1
  elsif line =~ /^Two Color Total Print Count = (\d+)/
    totalprint2c = $1
  elsif line =~ /^Single Color Total Print Count = (\d+)/
    totalprint1c = $1
  elsif line =~ /^Color Total Print Count = (\d+)/
    totalprintc = $1
  elsif line =~ /^Black & White Scanner Count = (\d+)/
    scanbw = $1
  elsif line =~ /^Two Color Scanner Count = (\d+)/
    scan2c = $1
  elsif line =~ /^Single Color Scanner Count = (\d+)/
    scan1c = $1
  elsif line =~ /^Full Color Scanner Count = (\d+)/
    scanfc = $1
  elsif line =~ /^Black & White Document Filing Print Count = (\d+)/
    fileprintbw = $1
  elsif line =~ /^Two Color Document Filing Print Count = (\d+)/
    fileprint2c = $1
  elsif line =~ /^Single Color Document Filing Count = (\d+)/
    fileprint1c = $1
  elsif line =~ /^Full Color Document Filing Print Count = (\d+)/
    fileprintfc = $1
  elsif line =~ /^I-Fax Receive Count = (\d+)/
    faxin = $1
  elsif line =~ /^Fax Receive Line1  = (\d+)/
    faxinline1 = $1
  elsif line =~ /^Fax Receive Line2 = (\d+)/
    faxinline2 = $1
  elsif line =~ /^Fax Receive Line3 = (\d+)/
    faxinline3 = $1
  elsif line =~ /^Black & White Other Print Count = (\d+)/
    otherprintbw = $1
  elsif line =~ /^Color Other Print Count = (\d+)/
    otherprintc = $1
  elsif line =~ /^I-Fax Send Count = (\d+)/
    faxout = $1
  elsif line =~ /^Fax Send Line1 = (\d+)/
    faxoutline1 = $1
  elsif line =~ /^Fax Send Line2 = (\d+)/
    faxoutline2 = $1
  elsif line =~ /^Fax Send Line3 = (\d+)/
    faxoutline3 = $1
  elsif line =~ /^Black & White Scan to HDD Count = (\d+)/
    hddscanbw = $1
  elsif line =~ /^Two Color Scan to HDD Count = (\d+)/
    hddscan2c = $1
  elsif line =~ /^Single Color Scan to HDD Count = (\d+)/
    hddscan1c = $1
  elsif line =~ /^Full Color Scan to HDD Count = (\d+)/
    hddscanfc = $1
  elsif line =~ /^Inserted Toner Number (Bk) = (\d+)/
    tonerbkin = $1
  elsif line =~ /^Inserted Toner Number (C) = (\d+)/
    tonercin = $1
  elsif line =~ /^Inserted Toner Number (M) = (\d+)/
    tonermin = $1
  elsif line =~ /^Inserted Toner Number (Y) = (\d+)/
    toneryin = $1
  elsif line =~ /^Toner NN End (Bk) = (\d+)/
    tonernnendbk = $1
  elsif line =~ /^Toner NN End (C) = (\d+)/
    tonernnendc = $1
  elsif line =~ /^Toner NN End (M) = (\d+)/
    tonernnendm = $1
  elsif line =~ /^Toner NN End (Y) = (\d+)/
    tonernnendy = $1
  elsif line =~ /^Toner End (Bk) = (\d+)/
    tonerendbk = $1
  elsif line =~ /^Toner End (C) = (\d+)/
    tonerendc = $1
  elsif line =~ /^Toner End (M) = (\d+)/
    tonerendm = $1
  elsif line =~ /^Toner End (Y) = (\d+)/
    tonerendy = $1
  elsif line =~ /^Toner Residual (Bk) = (.+)/
    tonerleftbk = $1
  elsif line =~ /^Toner Residual (C) = (.+)/
    tonerleftc = $1
  elsif line =~ /^Toner Residual (M) = (.+)/
    tonerleftm = $1
  elsif line =~ /^Toner Residual (Y) = (.+)/
    tonerlefty = $1
  end
end
