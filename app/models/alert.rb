class Alert < ActiveRecord::Base
  attr_accessible :alert_date, :device_name, :device_model, :device_serial, :device_code, :alert_msg, :notify_control_id

  belongs_to :notify_control

  def to_csv
    '"' + [self.alert_date.to_formatted_s(:db),self.notify_control.device_name,self.notify_control.device_model,self.notify_control.device_serial,self.notify_control.device_code,self.alert_msg].join('","') + '"'
  end
end
