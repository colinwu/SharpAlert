class Counter < ApplicationRecord
  
  belongs_to :device
  
  def self.reslevel
    { "0-25%" => 0, "25-50%" => 1, "50-75%" => 2, "75-100%" => 3}
  end
  
  def self.earliest_or_before(date,dev_id)
    a = Counter.where("date(status_date) = '#{date}' and device_id = #{dev_id} ").order('status_date').first
    if a.nil?
      a = Counter.where("date(status_date) < '#{date}' and device_id = #{dev_id}").order('status_date').last
    end
    return a
  end
  
  def self.latest_or_after(date,dev_id)
    a = Counter.where("date(status_date) = '#{date}' and device_id = #{dev_id}").order('status_date').last
    if a.nil?
      a = Counter.where("date(status_date) > '#{date}' and device_id = #{dev_id}").order('status_date').first
    end
    return a
  end
  
  def self.latest(dev_id)
    a = Counter.where("device_id = #{dev_id}").order('status_date').last
    return a
  end
  
end
