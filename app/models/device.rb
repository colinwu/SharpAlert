class Device < ActiveRecord::Base
  attr_accessible :name, :model, :serial, :code, :client_id, :ip
  has_many   :alerts, :dependent => :destroy
  has_one    :notify_control, :dependent => :destroy
  has_many   :counters, :dependent => :destroy
  belongs_to :client
  belongs_to :print_volume, :foreign_key => 'model', :primary_key => 'model'
  
  def name_model_serial
    "#{name}, #{model}, #{serial}"
  end
  
end
