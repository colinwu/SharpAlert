class Alert < ActiveRecord::Base
  attr_accessible :alert_date, :device_name, :device_model, :device_serial, :device_code, :alert_msg
end
