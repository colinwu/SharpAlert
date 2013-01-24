# Remove Alert records that are more than 1 year old

Alert.all(:conditions => "alert.date < (localtime - interval 1 year)").each do |a|
  a.delete
end