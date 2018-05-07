class Alert < ApplicationRecord

  belongs_to :device
  has_one :jam_stat, :dependent => :destroy
  has_one :sheet_count, :dependent => :destroy
  has_one :maint_counter, :dependent => :destroy
  has_many :toner_codes, :dependent => :destroy
  has_many :maint_codes, :dependent => :destroy
  has_many :service_codes, :dependent => :destroy

  def to_csv
    '"' + [self.alert_date.to_formatted_s(:db),self.device.name,self.device.model,self.device.serial,self.device.code,self.device.client.name,self.alert_msg].join('","') + '"'
  end
end
