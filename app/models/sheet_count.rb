class SheetCount < ActiveRecord::Base
  attr_accessible :bw, :color, :alert_id
  belongs_to :alert
end
