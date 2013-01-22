ndef = NotifyControl.find_by_device_serial 'default'
Alerts.all(:select => 'device_serial', :group => 'device_serial').each do |d|
  if NotifyControl.find_by_device_serial(d.device_serial).nil?
    puts d.device_serial
    n = NotifyControl.new
    n.device_serial = d.device_serial
    n.who = ndef.who
    n.how_often = ndef.how_often
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