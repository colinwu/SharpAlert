# Remove Alert records that are more than 2 year old and that are not toner related

Alert.where("created_at < (localtime - interval 2 year) and (not alert_msg regexp 'add toner' and not alert_msg regexp 'toner supply is low')").each do |a|
  a.delete
end

Alert.where("created_at < (localtime - interval 1 month) and 
alert_msg regexp 'Load paper'").each do |a|
  a.delete
end

# Counter.where("created_at < (localtime - interval 2 year)").each do |c|
#   c.delete
# end
# 
# Device.all.each do |d|
#   if d.alerts.empty? and d.counters.empty? and d.name != 'default'
#     d.destroy
#   end
# end
