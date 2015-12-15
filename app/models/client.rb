class Client < ActiveRecord::Base
  attr_accessible :name, :pattern
  before_destroy :reset_device_ownership
  has_many :devices
  
  def reset_device_ownership
    d_list = self.devices.each do |d|
      d.client_id = nil
      d.save
    end
  end
end
