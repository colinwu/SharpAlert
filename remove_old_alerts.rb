# Remove Alert records that are more than 1 year old

Alert.where("created_at < (localtime - interval 1 year)").each do |a|
  a.delete
end

Alert.where("created_at < (localtime - interval 1 month) and 
alert_msg regexp 'Load paper'").each do |a|
  a.delete
end
