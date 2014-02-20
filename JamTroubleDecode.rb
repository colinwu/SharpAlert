def parse_jam_history(f)
  f.read(1)
  jamcode = "%02x" % f.read(1).ord
  yr = '20' + "%02x" % f.read(1).ord
  mon = "%02x" % f.read(1).ord
  day = "%02x" % f.read(1).ord
  hr = "%02x" % f.read(1).ord
  min = "%02x" % f.read(1).ord
  sec = "%02x" % f.read(1).ord
  recdate = Time.new(yr,mon,day,hr,min,sec).to_s
  paper = "%02x" % f.read(1).ord
  paper_type = "%02x" % f.read(1).ord
  f.read(2) # skip over the 0xffff
  sheet_count_bw = f.read(4).unpack('L>')[0]
  sheet_count_colour = f.read(4).unpack('L>')[0]
  
  puts "On #{recdate}:"
  puts "  Jam Code:     #{jamcode}"
  puts "  Paper Code:   #{paper}"
  puts "  Paper Type:   #{paper_type}"
  puts "  BW count:     #{sheet_count_bw}"
  puts "  Colour count: #{sheet_count_colour}"
end
  
dir = ARGV[0]
f = File.open(dir + "/E-mail DIAG Jam Trouble Data.R05")

jamcode = 0

title = f.read(15)
if (title == 'JAM TROUBLE HIS')
#   f.read(35)
  f.read(3)
  dev = f.read(16)
  sn = f.read(16)
  puts "#{dev}, sn #{sn}"
  # read and convert send date and time
  yr = '20' + "%02x" % f.read(1).ord
  mon = "%02x" % f.read(1).ord
  day = "%02x" % f.read(1).ord
  hr = "%02x" % f.read(1).ord
  min = "%02x" % f.read(1).ord
  sec = "%02x" % f.read(1).ord
  sentdate = Time.new(yr,mon,day,hr,min).to_s
  puts "Sent date: #{sentdate}"
  dfcount = f.read(2).unpack('S>')[0]
  # start of first DF history record - most recent first
  puts "Number of DF jams: #{dfcount}"
  if (dfcount > 0)
    dfcount.times do
      parse_jam_history(f)
    end
    puts
  end
  
  # Process MB jams
  mbcount = f.read(2).unpack('S>')[0]
  puts "Number of MB jams: #{mbcount}"
  if (mbcount > 0)
    mbcount.times do
      parse_jam_history(f)
    end
    puts
  end
  
  # Process trouble history
  tbcount = f.read(2).unpack('S>')[0]
  puts "Number of Troubles: #{tbcount}"
  if (tbcount > 0)
    tbcount.times do
      tbcode = f.read(5)
      f.read(1)   # skip the LF
      yr = '20' + "%02x" % f.read(1).ord
      mon = "%02x" % f.read(1).ord
      day = "%02x" % f.read(1).ord
      hr = "%02x" % f.read(1).ord
      min = "%02x" % f.read(1).ord
      sec = "%02x" % f.read(1).ord
      recdate = Time.new(yr,mon,day,hr,min).to_s
      event = f.read(2).unpack('S>')[0]
      sheet_count_bw = f.read(4).unpack('L>')[0]
      sheet_count_colour = f.read(4).unpack('L>')[0]
    
      puts "On #{recdate}:"
      puts "  Trouble Code: #{tbcode}"
      puts "  BW count:     #{sheet_count_bw}"
      puts "  Colour count: #{sheet_count_colour}"
    end
  end
end
