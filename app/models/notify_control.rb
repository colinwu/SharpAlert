class NotifyControl < ActiveRecord::Base
  attr_accessible :serial, :model, :local_admin, :tech, :jam, :toner_low, :toner_empty, :paper, :service, :pm, :waste_almost_full, :waste_full, :job_log_full, :jam_sent, :toner_low_sent, :toner_empty_sent, :paper_sent, :service_sent, :pm_sent, :waste_almost_full_sent, :waste_full_sent, :job_log_full_sent, :name, :client_id, :code

  belongs_to :device
  # TODO remove after 'populate_device_table.rb' has ran successfully
  has_many :alerts
  
end
