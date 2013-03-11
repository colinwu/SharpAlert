class NotifyControl < ActiveRecord::Base
  attr_accessible :device_serial, :device_model, :who, :jam, :toner_low, :toner_empty, :paper, :service, :pm, :waste_almost_full, :waste_full, :job_log_full, :jam_sent, :toner_low_sent, :toner_empty_sent, :paper_sent, :service_sent, :pm_sent, :waste_almost_full_sent, :waste_full_sent, :job_log_full_sent, :device_name

  has_many :alerts
end
