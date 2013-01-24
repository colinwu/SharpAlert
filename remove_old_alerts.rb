# Remove Alert records that are more than 1 year old

Alert.all(:conditions => "created_at < (localtime - interval 1 year)").each do |a|
  a.delete
end