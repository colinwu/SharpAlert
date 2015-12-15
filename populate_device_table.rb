NotifyControl.all.each do |n|
  d = Device.new(:name => n.name, :model => n.model, :serial => n.serial, :code => n.code, :client_id => n.client_id)
  d.save
  n.device_id = d.id
  n.save
  n.alerts.each do |a|
    a.device_id = d.id
    a.save
  end
end