Client.all.each do |client|
  alldevs = Device.where("(alert_msg regexp 'toner supply' or alert_msg regexp 'add toner') and client_id = #{client.id}").joins(:alerts).group(:device_id).order(:name)
  # alldevs = Device.where('name = "yr-mf-202"')
  threshold = 5 * 24 * 3600 # should see an "Add toner" no more than 5 days after a "Toner low"
  last_low = {'Bk' => [], 'C' => [], 'M' => [], 'Y' => []}
  last_out = {'Bk' => [], 'C' => [], 'M' => [], 'Y' => []}
  data = {'date' => {'low' => {'Bk' => [], 'C' => [], 'M' => [], 'Y' => []}, 
                     'out' => {'Bk' => [], 'C' => [], 'M' => [], 'Y' => []}}}
  puts "Client: #{client.name}"
  alldevs.each do |d|
    ['Bk', 'C', 'M', 'Y'].each do |c|
      alerts = d.alerts.where("(alert_msg regexp 'toner supply') and toner_codes.colour = '#{c}'").joins(:toner_codes).order(:alert_date)
      alerts.each_index do |i|
        break if (i == alerts.length - 1)
        this_a = alerts[i]
        next_a = alerts[i+1]
        data['low'][c] << this_a.alert_date
        if ((next_a.alert_date - this_a.alert_date) > threshold)
          add_toner = d.alerts.where("alert_msg regexp 'add toner' and toner_codes.colour = '#{c}' and alert_date >= '#{this_a.alert_date}' and alert_date < '#{next_a.alert_date}'").joins(:toner_codes).limit(1)
          