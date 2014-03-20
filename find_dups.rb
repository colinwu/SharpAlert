type = ARGV.shift

Alert.where("alert_msg regexp '#{type}'").group(:alert_date, :device_id).count.each do |k,v|
  if (v > 1)
    alright = Array.new
    suspect = Array.new
    keep = Array.new
    
    alerts = Alert.where("alert_date = '#{k[0]}' and device_id = #{k[1]} and alert_msg regexp '#{type}'").order(:created_at)
    alerts.each do |a| # there could be more than 2
      if ((a.created_at.to_date - a.alert_date.to_date) > 2)
        suspect << a
      else
        alright << a
      end
    end
    if (suspect.empty?)
      puts "There are no suspicious alerts. Here are the ok one:"
      puts alright.inspect
      puts "----------------"
    elsif (suspect.length > 1)
      puts "There are more than one suspect alerts. You'll need to deal with them."
      puts suspect.inspect
      puts "Original alert(s):"
      puts alright.inspect
      puts "----------------"
    else
      a = suspect.shift
      if (a.alert_msg =~ /call for service/i)
        unless a.service_codes.nil?
          keep << a.id
        end
      elsif (a.alert_msg =~ /maintenance required/i)
        unless a.maint_codes.nil?
          keep << a.id
        end
      elsif (a.alert_msg =~ /add toner/ or a.alert_msg =~ /toner required/)
        unless a.toner_codes.nil?
          keep << a.id
        end
      else
        unless a.maint_counter.nil?
          keep << a.id
        end
      end
    end
    unless (keep.empty?)
      alright.each do |a|
        a.destroy
      end
    end
  end
end