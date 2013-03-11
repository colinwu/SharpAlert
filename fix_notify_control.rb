NotifyControl.all.each do |n|
  unless n.alerts.empty?
    n.device_name = n.alerts.last.device_name
    n.save
  end
end