class TonerCode < ActiveRecord::Base
  attr_accessible :colour, :alert_id
  belongs_to :alert
end
