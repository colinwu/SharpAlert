class Alert < ActiveRecord::Base
  attr_accessible :alert_date, :alert_msg, :notify_control_id

  belongs_to :device
  has_one :jam_stat
  has_one :sheet_count
  has_one :maint_counter

  def to_csv
    '"' + [self.alert_date.to_formatted_s(:db),self.device.name,self.device.model,self.device.serial,self.device.code,self.device.client.name,self.alert_msg].join('","') + '"'
  end
end
