class Device < ActiveRecord::Base
  attr_accessible :name, :model, :serial, :code, :client_id
  has_many   :alerts
  has_one    :notify_control
  belongs_to :client
end
