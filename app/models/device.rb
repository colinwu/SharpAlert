class Device < ActiveRecord::Base
  attr_accessible :name, :model, :serial, :code, :client_id
  has_many   :alerts, :dependent => :destroy
  has_one    :notify_control, :dependent => :destroy
  belongs_to :client
end
