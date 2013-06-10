class Alert < ActiveRecord::Base
  attr_accessible :alert_date, :alert_msg, :notify_control_id

  belongs_to :device
  # TODO remove after 'populate_device_table.rb' has ran successfully
  belongs_to :notify_control

  def to_csv
    '"' + [self.alert_date.to_formatted_s(:db),self.device.name,self.device.model,self.device.serial,self.device.code,self.device.client.name,self.alert_msg].join('","') + '"'
  end
end
