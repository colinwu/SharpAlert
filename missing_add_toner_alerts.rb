Client.all.each do |client|
  alldevs = Device.where("(alert_msg regexp 'toner supply' or alert_msg regexp 'add toner') and client_id = #{client.id}").joins(:alerts).group(:device_id)
  # alldevs = Device.where('name = "yr-mf-202"')
  threshold = 5 * 24 * 3600 # "low" alerts within 5 days of each other are considered to be for the same cartridge
  lows = {'Bk' => [], 'C' => [], 'M' => [], 'Y' => []}
  puts "Client: #{client.name}"
  alldevs.each do |d|
    # get all the "toner supply is low" alerts for this device
    ['Bk', 'C', 'M', 'Y'].each do |c|
      lows[c] = d.alerts.where("alert_msg regexp 'toner supply' and toner_codes.colour = '#{c}'").joins(:toner_codes).order(:alert_date)
      lows[c].each_index do |i|
        break if (i == lows[c].length - 1)
        # for each of the "toner low" alerts see if there is a corresponding "add toner" within 5 days
        this_a = lows[c][i]
        next_a = lows[c][i+1]
        if ((next_a.alert_date - this_a.alert_date) > threshold)
          add_toner = d.alerts.where("alert_msg regexp 'add toner' and toner_codes.colour = '#{c}' and alert_date >= '#{this_a.alert_date}' and alert_date < '#{next_a.alert_date}'").joins(:toner_codes).limit(1)
#           puts "#{d.name}: #{this_a.alert_date.to_date} #{c} low"
          if add_toner.empty?
            puts "#{d.name}: No 'add #{c} toner' alert between #{this_a.alert_date.to_date} and #{next_a.alert_date.to_date}"
#             puts "#{d.name}: Missing #{c} empty alert"
          else
#             puts "#{d.name}: #{add_toner[0].alert_date.to_date} #{c} empty"
          end
        end
      end
    end
  end
end