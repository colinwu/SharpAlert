

if File.exists?('/home/sharpmon/public_html/alerts.csv')
  r = CsvMapper.import('/home/sharpmon/public_html/alerts.csv') do
    start_at_row 1
    [alert_date,device_name,device_model,device_ser,device_code,alert_msg]
  end
  r.each do |row|
    ndef = NotifyControl.find_by_device_serial 'default'
    a = Alert.create :alert_date => row.alert_date,
                      :device_name => row.device_name,
                      :device_model => row.device_model,
                      :device_serial => row.device_ser,
                      :device_code => row.device_code,
                      :alert_msg => row.alert_msg
    
    if NotifyControl.find_by_device_serial(row.device_ser).nil?
      n = NotifyControl.new
      n.device_serial = row.device_ser
      n.who = ndef.who
      n.jam = ndef.jam
      n.toner_low = ndef.toner_low
      n.toner_empty = ndef.toner_empty
      n.paper = ndef.paper
      n.service = ndef.service
      n.pm = ndef.pm
      n.waste_almost_full = ndef.waste_almost_full
      n.waste_full = ndef.waste_full
      n.job_log_full = ndef.job_log_full
      n.save
    end
  end
end
