NotifyControl.find_each do |a|
  unless a.alerts.empty?
    a.device_code = a.alerts[0].device_code
    a.save
  end
end