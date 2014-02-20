class JamStat < ActiveRecord::Base
  attr_accessible :jam_code, :paper_type, :paper_code, :jam_type, :alert_id
  belongs_to :alert
  
end
