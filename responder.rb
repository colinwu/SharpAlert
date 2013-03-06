# Respond to an emailed request for alert list. Replies with .csv file
# Search criteria are specified on Subject: line similar to GET request; i.e.
# Subject: name_q=yr-mf-111;date_q=2013-03-05;msg_q=service
#
require './lib/ext/string.rb'

while (line = gets)
  if (line =~ /^From:.*<(.*)>/)
    sender = $1;
  elsif (line =~ /^Subject: Request:(.+)/)
    param = $1;
  end
  unless sender.nil? or param.nil?
    break;
  end
end

params = Hash.new
unless (param.nil? or param.empty?)
  param.strip!
  param.split(/;/).each do |p|
    q = p.split(/=/)
    params[q[0]] = q[1]
  end
end

where_array = Array.new
condition_array = ['place holder']
if (not params['date_q'].nil? and not params['date_q'].empty?)
  @date_q = params['date_q']
  condition_array << @date_q.condition
  where_array << @date_q.where('alert_date')
end
if (not params['name_q'].nil? and not params['name_q'].empty?)
  @name_q = params['name_q']
  condition_array << @name_q.condition
  where_array << @name_q.where('device_name')
end
if(not params['model_q'].nil? and not params['model_q'].empty?)
  @model_q = params['model_q']
  condition_array << @model_q.condition
  where_array << @model_q.where('device_model')
end
if(not params['serial_q'].nil? and not params['serial_q'].empty?)
  @serial_q = params['serial_q']
  condition_array << @serial_q.condition
  where_array << @serial_q.where('device_serial')
end
if(not params['code_q'].nil? and not params['code_q'].empty?)
  @code_q = params['code_q']
  where_array << @code_q.where('device_code')
  condition_array << @code_q.condition
end
if(not params['msg_q'].nil? and not params['msg_q'].empty?)
  @msg_q = params['msg_q']
  where_array << @msg_q.where('alert_msg')
  condition_array << @msg_q.condition
end
unless where_array.empty?
  condition_array[0] = where_array.join(' and ')
else
  condition_array = []
end

puts condition_array.inspect

csv_file = '/tmp/alerts_list-' + Time.now.to_f.to_s.sub!('.','') + '.csv'
csv = File.new(csv_file,"w")
csv.puts'"alert date","device name","device_model","serial number","machine code","message"'
Alert.all(:conditions => condition_array).each do |a|
  puts "#{a.device_name},#{a.alert_date},#{a.alert_msg}"
  puts '==> ' + a.to_csv
  csv.puts a.to_csv
end

# Write the csv data to a temporary file ...
csv.close

# ... then send it as an attachment
NotifyMailer.email_response(sender,csv_file).deliver
File.unlink(csv_file)