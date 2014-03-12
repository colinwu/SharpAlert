mc_bydev = Hash.new
Device.all.each do |d|
  mc = MaintCounter.joins(:alert).where("device_id = #{d.id} and (drum_life_used_b > 85 or drum_life_used_m > 85 or drum_life_used_c > 85 or drum_life_used_y > 85 or dev_life_used_b > 85 or dev_life_used_m > 85 or dev_life_used_c > 85 or dev_life_used_y > 85)").order(:alert_date).last
  unless mc.nil?
    mc_bydev[d.id] = mc
  end
end

mc_bydev.each do |key,val|
  puts "#{Device.find(key).name}: #{val.alert.alert_date} #{val.drum_life_used_b}, #{val.drum_life_used_c}, #{val.drum_life_used_m}, #{val.drum_life_used_y}"
end