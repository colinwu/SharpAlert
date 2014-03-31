devs = Device.joins(:alerts).where("alert_msg regexp 'toner supply' or alert_msg regexp 'add toner'").order(:name,:serial).uniq

devs.each do |dev|
  where_array = ["(alert_msg regexp 'toner supply is low') and device_id = ?", dev.id]
  @alerts = Alert.where(where_array).joins(:toner_codes).group('date(alert_date)', 'toner_codes.colour').count

  toner_low = {'Bk' => [], 'C' => [], 'M' => [], 'Y' => []}
  last_low = {}
  where_array << '' # just a couple of placeholders
  where_array << ''
  date_diff = 0
  where_array[0] = "(alert_msg regexp 'toner supply is low') and device_id = ? and toner_codes.colour = ? and date(alert_date) = ?"
  @alerts.each do |key,val|
    where_array[-1] = key[0] # date
    where_array[-2] = key[1] # colour
    a = Alert.where(where_array).order('alert_date').joins(:toner_codes).first
    unless (last_low[key[1]].nil?)
      prev_alert = last_low[key[1]]
      date_diff = ((a.alert_date - prev_alert.alert_date)/86400).to_i
      if (date_diff > 10)
        toner_low[key[1]] << {'date_diff' => date_diff}
        unless (prev_alert.sheet_count.nil? or a.sheet_count.nil?)
          if (key[1] == 'Bk')
            toner_low[key[1]][-1]['page_diff'] = a.sheet_count.bw - prev_alert.sheet_count.bw
          else
            toner_low[key[1]][-1]['page_diff'] = a.sheet_count.color - prev_alert.sheet_count.color
          end
        end
      end
    end
    if (date_diff > 5 or last_low[key[1]].nil?)
      last_low[key[1]] = a 
    end
  end


  where_array = ["(alert_msg regexp 'add toner') and device_id = ?", dev.id]
  @alerts = Alert.where(where_array).joins(:toner_codes).group('date(alert_date)', 'toner_codes.colour').count

  toner_out = {'Bk' => [], 'C' => [], 'M' => [], 'Y' => []}
  last_out = {}
  where_array << '' # just a couple of placeholders
  where_array << ''
  date_diff = 0
  where_array[0] = "(alert_msg regexp 'add toner') and device_id = ? and toner_codes.colour = ? and date(alert_date) = ?"

  @alerts.each do |key,val|
    where_array[-1] = key[0]
    where_array[-2] = key[1]
    a = Alert.where(where_array).order('alert_date').joins(:toner_codes).first
    unless (last_out[key[1]].nil?)
      prev_alert = last_out[key[1]]
      date_diff = ((a.alert_date - prev_alert.alert_date)/86400).to_i
      if (date_diff > 10)
        toner_out[key[1]] << {'date_diff' => date_diff}
        unless (prev_alert.sheet_count.nil? or a.sheet_count.nil?)
          if (key[1] == 'Bk')
            toner_out[key[1]][-1]['page_diff'] = a.sheet_count.bw - prev_alert.sheet_count.bw
          else
            toner_out[key[1]][-1]['page_diff'] = a.sheet_count.color - prev_alert.sheet_count.color
          end
        end
      end
    end
    if (date_diff > 5 or last_out[key[1]].nil?)
      last_out[key[1]] = a 
    end
  end
  
  # Calculate when new toner will be needed for this device
  # NOTE How do we use the page count data??? I think linear regression is probably the right way,
  # which means rather than keeping the page diff between alerts, I should remember the actual 
  # page count and calculate the equation here.
  # NOTE But maybe for now just use the overall average number of pages per day between alerts
  # together with the average number of pages per interval
  # 
  low_d_ave = {}
  low_pages_per_interval = {}
  low_pages_per_day = {}
  toner_low.each do |c, data|
    unless data.empty?
      day_int = 0
      page_int = 0
      d_total = 0
      p_total = 0
      ppd_total = 0
      data.each do |d|
        d_total += d['date_diff']
        day_int += 1
        unless d['page_diff'].nil?
          p_total += d['page_diff']
          page_int += 1
          ppd_total += d['page_diff']/d['date_diff']
        end
      end
      low_d_ave[c] = d_total / day_int
      unless page_int == 0
        low_pages_per_interval[c] = p_total / page_int
        low_pages_per_day[c] = ppd_total / page_int
      end
    end
  end
  
  out_d_ave = {}
  out_pages_per_interval = {}
  out_pages_per_day = {}
  toner_out.each do |c, data|
    unless data.empty?
      day_int = 0
      page_int = 0
      d_total = 0
      p_total = 0
      ppd_total = 0
      data.each do |d|
        d_total += d['date_diff'] # elapsed days since the first alert
        day_int += 1              # number of alert intervals based on date
        unless d['page_diff'].nil?
          p_total += d['page_diff'] # total number of pages printed since first alert
          page_int += 1             # number of alert intervals based on pages
          ppd_total += d['page_diff']/d['date_diff']
        end
      end
      out_d_ave[c] = d_total / day_int
      unless page_int == 0
        out_pages_per_interval[c] = p_total / page_int
        out_pages_per_day[c] = ppd_total / page_int
      end
    end
  end
  
  puts "\n---- #{dev.name}, #{dev.serial}"
  ['Bk','C','M','Y'].each do |c|
    unless last_low[c].nil? or low_d_ave[c].nil?
      puts "based on #{toner_low[c].length+1} toner low alerts..."
      puts "  date data says #{c} will run low on " + (last_low[c].alert_date + low_d_ave[c]*86400).to_date.to_s
      if (low_pages_per_day[c] != 0 and !low_pages_per_day[c].nil?)
        puts "  page data says #{c} will run low on " + (last_low[c].alert_date + (low_pages_per_interval[c]/low_pages_per_day[c])*86400).to_date.to_s
      end
    end
  end
  ['Bk','C','M','Y'].each do |c|
    unless last_out[c].nil? or out_d_ave[c].nil?
      puts "based on #{toner_out[c].length+1} toner out alerts..."
      puts "  date data says #{c} will run out on " + (last_out[c].alert_date + out_d_ave[c]*86400).to_date.to_s
      if (out_pages_per_day[c] != 0 and !out_pages_per_day[c].nil?)
        puts "  page data says #{c} will run out on " + (last_out[c].alert_date + (out_pages_per_interval[c]/out_pages_per_day[c])*86400).to_date.to_s
      end
    end
  end
end