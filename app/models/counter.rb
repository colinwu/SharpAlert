class Counter < ActiveRecord::Base
  attr_accessible :status_date, :copybw, :copy2c, :copy1c, :copyfc, :printbw, :printfc, :totalprintbw, :totalprint2c, :totalprint1c, :totalprintc, :scanbw, :scan2c, :scan1c, :scanfc, :fileprintbw, :fileprint2c, :fileprint1c, :fileprintfc, :faxin, :faxinline1, :faxinline3, :otherprintbw, :otherprintc, :faxout, :faxoutline1, :faxoutline2, :faxoutline3, :hddscanbw, :hddscan2c, :hddscan1c, :hddscanfc, :tonerbkin, :tonercin, :tonermin, :toneryin, :tonernnendbk, :tonernnendc, :tonernnendm, :tonernnendy, :tonerendbk, :tonerendc, :tonerendm, :tonerendy, :tonerleftbk, :tonerleftc, :tonerleftm, :tonerlefty, :device_id
  
  belongs_to :device
  
  def self.reslevel
    { "0-25%" => 0, "25-50%" => 1, "50-75%" => 2, "75-100%" => 3}
  end
end
