dir = ARGV[0]
f = File.open(dir + "/E-mail DIAG Jam Trouble Data.R05")

jamcode = 0

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
    puts "First DF/MB record date: #{recdate}"
  end
  if (sentdate == recdate)
    puts "The jam code is #{jamcode}"
  else   # skip past the rest of the DF history
    f.read(2) # skip over the MB count - we don't care
    f.read(1)
    jamcode = '%02x' % f.read(1).ord
    yr = "%02x" % f.read(1).ord
    mon = "%02x" % f.read(1).ord
    day = "%02x" % f.read(1).ord
    hr = "%02x" % f.read(1).ord
    min = "%02x" % f.read(1).ord
    sec = "%02x" % f.read(1).ord
    recdate = yr + mon + day + hr + min
    puts "First MB record date: #{recdate}"
    if (sentdate == recdate)
      puts "The jam code is #{jamcode}"
    end
  end
end