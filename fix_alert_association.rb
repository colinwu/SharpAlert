# populate notify_control_id column in alerts table
Alert.all.each do |a|
  nc = NotifyControl.find_by_device_serial(a.device_serial)
  a.notify_control_id = nc.id
  a.save
  if nc.device_model.nil?
    nc.device_model = a.device_model
    nc.save
  end
end