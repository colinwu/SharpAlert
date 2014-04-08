devlist = Device.order(:name)
threshold = 3600 * 24 * 14 # Look two weeks ahead

devlist.each do |device|
  alerts = device.alerts.order('alert_date desc').joins(:maint_counter)
  unless alerts.empty?
    # find minimum y
    mind = Hash.new
    minv = Hash.new
    stuff = {'drum' => {'b' => {'time' => [], 'age' => []},
                        'c' => {'time' => [], 'age' => []},
                        'm' => {'time' => [], 'age' => []},
                        'y' => {'time' => [], 'age' => []}
                       },
           'dev'  =>  {'b' => {'time' => [], 'age' => []},
                       'c' => {'time' => [], 'age' => []},
                       'm' => {'time' => [], 'age' => []},
                       'y' => {'time' => [], 'age' => []}
                      }
           }
    colour = {'b' => 'Black', 'c' => 'Cyan', 'm' => 'Magenta', 'y' => 'Yellow'}
    
    # Ignore the 100% data points because once the ages reache 100% they peg there and would
    # tend to skew the results if they're not serviced right away.
    ['b','c','m','y'].each do |color|
      mind[color] = 99
      minv[color] = 99
    end
    alerts.each do |a|
      if (a.maint_counter.drum_life_used_b <= mind['b'])
        mind['b'] = a.maint_counter.drum_life_used_b.to_i
        stuff['drum']['b']['time'] << a.alert_date.to_i
        stuff['drum']['b']['age'] << mind['b']
      end
      if (a.maint_counter.drum_life_used_c <= mind['c'])
        mind['c'] = a.maint_counter.drum_life_used_c.to_i
        stuff['drum']['c']['time'] << a.alert_date.to_i
        stuff['drum']['c']['age'] << mind['c']
      end
      if (a.maint_counter.drum_life_used_m <= mind['m'])
        mind['m'] = a.maint_counter.drum_life_used_m.to_i
        stuff['drum']['m']['time'] << a.alert_date.to_i
        stuff['drum']['m']['age'] << mind['m']
      end
      if (a.maint_counter.drum_life_used_y <= mind['y'])
        mind['y'] = a.maint_counter.drum_life_used_y.to_i
        stuff['drum']['y']['time'] << a.alert_date.to_i
        stuff['drum']['y']['age'] << mind['y']
      end
      if (a.maint_counter.dev_life_used_b <= minv['b'])
        minv['b'] = a.maint_counter.dev_life_used_b.to_i
        stuff['dev']['b']['time'] << a.alert_date.to_i
        stuff['dev']['b']['age'] << minv['b']
      end
      if (a.maint_counter.dev_life_used_c <= minv['c'])
        minv['c'] = a.maint_counter.dev_life_used_c.to_i
        stuff['dev']['c']['time'] << a.alert_date.to_i
        stuff['dev']['c']['age'] << minv['c']
      end
      if (a.maint_counter.dev_life_used_m <= minv['m'])
        minv['m'] = a.maint_counter.dev_life_used_m.to_i
        stuff['dev']['m']['time'] << a.alert_date.to_i
        stuff['dev']['m']['age'] << minv['m']
      end
      if (a.maint_counter.dev_life_used_y <= minv['y'])
        minv['y'] = a.maint_counter.dev_life_used_y.to_i
        stuff['dev']['y']['time'] << a.alert_date.to_i
        stuff['dev']['y']['age'] << minv['y']
      end
    end

    linear = {'drum' => {},
              'dev'  => {}
             }
    r2 = {'drum' => {},
          'dev'  => {}
         }
    stuff.each do |type,color|
      color.each do |c,data|
        linear[type][c] = Regression::Linear.new(data['time'], data['age'])
        r2[type][c] = Regression::CorrelationCoefficient.new(data['time'], data['age']).pearson
      end
    end
    
    status = "---- #{device.name} (#{device.serial})\n"
    have_output = false
    now = Time.now.to_i
    stuff.each do |type, color|
      color.keys.each do |c|
        slope = linear[type][c].slope
        intercept = linear[type][c].intercept
        unless (slope <= 0 or slope.nan?)
          duedate = ((100 - intercept)/slope).to_i
          if (duedate - now) < threshold
            status += "#{colour[c]} #{type} due around " + Time.at(duedate).to_date.to_s + " (correlation coeff = #{r2[type][c].round(3)})\n"
            have_output = true
          end
        end
      end
    end
    if have_output
      puts status
    end
  end
end