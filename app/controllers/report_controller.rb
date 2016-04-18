class ReportController < ApplicationController
  def index
    # Show list of available special reports - maybe with fields for any optional
    # settings for each report
    @days = 7
  end
  
  # Retrieve count of specified alerts (for each day) for specified devices. 
  # Devices can be specified by name, model, sn, code, or client.
  def frequency
    @days = 7 # default: look at last 7 days
    unless (params[:commit].nil?)
      where_array = Array.new
      condition_array = ['place holder']
      if (not params[:days].nil? and not params[:days].empty?)
        @days = params[:days]
      end
      condition_array << @days
      where_array << "alert_date > date_sub(curdate(), interval ? day) and alert_date < curdate()"
      comment_array = ["For last #{@days} days"]
      if (not params['name_q'].nil? and not params['name_q'].empty?)
        @name_q = params[:name_q]
        condition_array << @name_q.condition
        where_array << @name_q.where('devices.name')
        comment_array << "Name = #{@name_q}"
      end
      if(not params['model_q'].nil? and not params['model_q'].empty?)
        @model_q = params[:model_q]
        condition_array << @model_q.condition
        where_array << @model_q.where('devices.model')
        comment_array << "Model = #{@model_q}"
      end
      if(not params['serial_q'].nil? and not params['serial_q'].empty?)
        @serial_q = params[:serial_q]
        condition_array << @serial_q.condition
        where_array << @serial_q.where('devices.serial')
        comment_array << "Serial # = #{@serial_q}"
      end
      if(not params['code_q'].nil? and not params['code_q'].empty?)
        @code_q = params[:code_q]
        where_array << @code_q.where('devices.code')
        condition_array << @code_q.condition
        comment_array << "Machine Code = #{@code_q}"
      end
      if (not params[:client].nil? and not params[:client][:name].empty?)
        @client = Client.new
        @client['name'] = params[:client][:name]
        where_array << @client.name.where('clients.name')
        condition_array << @client.name.condition
        comment_array << "Client Name contains #{@client.name}"
      end
      if(not params['msg_q'].nil? and not params['msg_q'].empty?)
        @msg_q = params[:msg_q]
        where_array << @msg_q.where('alert_msg')
        condition_array << @msg_q.condition
        comment_array << "Message contains #{@msg_q}"
      end
      unless where_array.empty?
        condition_array[0] = where_array.join(' and ')
        @comment = comment_array.join(' and ')
      else
        condition_array = []
      end
    end
    @alert_counts = Alert.where(condition_array).joins(:device => :client).group('device_id','date(alert_date)').order('devices.name').count
    @devices = @alert_counts.keys.map { |key| key[0] }.uniq
    @dates = (Date.today-@days.to_i..Date.today-1).map {|d| d }
  end

  # Jam Code frequency per device
  def jam_code_stats
    unless (params['days'].nil?)
      @days = params['days']
      @code_list = JamStat.select('jam_code').group('jam_code').joins(:alert).where(["alert_date > date_sub(now(),interval ? day)", @days])
    else
      @code_list = JamStat.select('jam_code').group('jam_code')
    end
    @dev_stats = Hash.new
    @dev_list = Device.order(:name)
    @dev_list.each do |d|
      where_array = ["alert_msg = 'Misfeed has occurred.' and device_id = ?", d.id]
      unless @days.nil?
        where_array[0] += " and alert_date > date_sub(now(),interval ? day)"
        where_array << @days
      end
      g = JamStat.where(where_array).joins(:alert).group('jam_code').select('jam_stats.jam_code').count
      unless g.empty?
        @dev_stats[d.id] = g
      end
    end
  end
  
  # Jam code history for a device/code combination
  def jam_history
    @uri = request.env['REQUEST_URI'].sub(/[&?]*days=\d+&*/, '')
    
    if (params.nil? or params[:id].empty? or params[:code].empty?)
      # should show an error message
    else
      @dev = Device.find params[:id]
      @jam = params[:code]
      where_array = ["device_id = ? and jam_code = ?",@dev.id,@jam]
      unless (params[:days].nil? or params[:days].empty?)
        @days = params[:days]
        where_array[0] += " and alert_date > date_sub(now(),interval ? day)"
        where_array << @days
      end
      @alerts = Alert.where(where_array).joins(:jam_stat).order(:alert_date)
      @data = {'date' => [], 'date_diff' => [], 'bw_count' => [], 'bw_diff' => [], 'c_count' => [], 'c_diff' => []}
      prev_alert = Alert.new
      @alerts.each do |a|
        @data['date'] << a.alert_date
        @data['bw_count'] << a.sheet_count.bw
        @data['c_count'] << a.sheet_count.color
        unless prev_alert.id.nil?
          diff = a.alert_date.to_i - prev_alert.alert_date.to_i
          d,h,m,s = (diff/86400).to_i, (diff%86400/3600).to_i, (diff%3600/60).to_i, (diff%60).to_i
          @data['date_diff'] << ((d > 0) ? ((d == 1) ? "#{d} day " : "#{d} days ") : '') + "#{'%02d' % h}:#{'%02d' % m}:#{'%02d' % s}"
          @data['bw_diff'] << a.sheet_count.bw - prev_alert.sheet_count.bw
          @data['c_diff'] << a.sheet_count.color - prev_alert.sheet_count.color
        else
          @data['date_diff'] << ' '
          @data['bw_diff'] << ' '
          @data['c_diff'] << ' '
        end
        prev_alert = a
      end
    end
    @title = "Jam Code #{JamCode.xlate(@jam)} History for #{@dev.name}"
  end
  
  def full_jam_history
    @dev = Device.find params[:id]
    @data = Hash.new
    @codes = Array.new
    
    # Now build display data array @data
    where_array = ["alert_msg = 'Misfeed has occurred.' and device_id = ?", @dev.id]
    unless (params[:days].nil? or params[:days].empty?)
      @days = params[:days]
      where_array[0] += " and alert_date > date_sub(now(),interval ? day)"
      where_array << @days.to_i
    end
    @alerts = Alert.where(where_array).joins(:jam_stat).order(:alert_date)
    unless @alerts.empty?
      # first retrieve complete list of jam codes we know about for the device    
      @alerts.each do |a|
        unless a.jam_stat.nil?
          @codes << a.jam_stat.jam_code
        end
      end
      unless @codes.length < 2
        @codes.uniq!.sort!
      end
      
      last_entry = Hash.new
      prev_alert = Hash.new
      @alerts.each do |a|
        unless last_entry[a.jam_stat.jam_code].nil?
          prev_alert = last_entry[a.jam_stat.jam_code]
          d_diff = a.alert_date - prev_alert.alert_date
          if (a.jam_stat.jam_type == 'DF')
            # Jam is a document feeder misfeed, so count original difference, rather than output
            p_diff = a.maint_counter.spf_count - prev_alert.maint_counter.spf_count
          else
            p_diff = (a.sheet_count.bw + a.sheet_count.color) - 
                    (prev_alert.sheet_count.bw + prev_alert.sheet_count.color)
          end
          @data[a.alert_date] = 
                    {a.jam_stat.jam_code => 
                     {'d_date' => d_diff,
                      'd_page' => p_diff}
                    }
        else
          @data[a.alert_date] = {a.jam_stat.jam_code => {'d_date' => '*', 'd_page' => '*'}}
        end
        last_entry[a.jam_stat.jam_code] = a
      end
    else
      # Device doesn't return dealer attachments
      @alerts = Alert.where(where_array).order(:alert_date)
#       prev_alert = Alert.new
      @codes = ['*']
      @alerts.each do |a|
        unless prev_alert.nil?
          d_diff = a.alert_date - prev_alert.alert_date
          @data[a.alert_date] = {'*' => {'d_date' => d_diff, 'd_page' => ' '}}
        else
          @data[a.alert_date] = {"*" => {'d_date' => '*', 'd_page' => ' '}}
        end
        prev_alert = a
      end
    end
  end
  
  def full_cfs_history
    @dev = Device.find params[:id]
    @codes = Array.new
    @data = Hash.new
    
    where_array = ["alert_msg regexp 'call for service' and device_id = ?", @dev.id]
    unless (params[:days].nil? or params[:days].empty?)
      @days = params[:days]
      where_array[0] += " and alert_date > date_sub(now(),interval ? day)"
      where_array << @days.to_i
    end
    @alerts = Alert.where(where_array).joins(:service_codes).order(:alert_date).uniq
    
    @alerts.each do |a|
      unless a.service_codes.empty?
        a.service_codes.each do |s|
          @codes << s.code
        end
      end
    end
    unless @codes.length < 2
      @codes.uniq!.sort!
    end
    
    last_entry = Hash.new
    prev_alert = Hash.new
    @alerts.each do |a|
      a.service_codes.each do |sc|
        unless last_entry[sc.code].nil?
          prev_alert = last_entry[sc.code]
          d_diff = a.alert_date - prev_alert.alert_date
          unless (a.sheet_count.nil? or prev_alert.sheet_count.nil?)
            p_diff = (a.sheet_count.bw + a.sheet_count.color) - (prev_alert.sheet_count.bw + prev_alert.sheet_count.color)
          else
            p_diff = '-'
          end
          if (@data[a.alert_date].nil?)
            @data[a.alert_date] = {sc.code => {'d_date' => d_diff, 'd_page' => p_diff}}
          else
            @data[a.alert_date][sc.code] = {'d_date' => d_diff, 'd_page' => p_diff}
          end
        else
          if (@data[a.alert_date].nil?)
            @data[a.alert_date] = {sc.code => {'d_date' => '*', 'd_page' => '*'}}
          else
            @data[a.alert_date][sc.code] = {'d_date' => '*', 'd_page' => '*'}
          end
        end
        last_entry[sc.code] = a
      end
    end
    @title = "Call for Service History for #{@dev.name}"
    render :template => 'report/history.html.erb'
  end
  
  def full_maint_history
    @dev = Device.find params[:id]
    @codes = Array.new
    @data = Hash.new
    where_array = ["alert_msg regexp 'maintenance required' and device_id = ?", @dev.id]
    unless (params[:days].nil? or params[:days].empty?)
      @days = params[:days]
      where_array[0] += " and alert_date > date_sub(now(),interval ? day)"
      where_array << @days.to_i
    end
    @alerts = Alert.where(where_array).joins(:maint_codes).order(:alert_date).uniq
    
    @alerts.each do |a|
      unless a.maint_codes.empty?
        a.maint_codes.each do |s|
          @codes << s.code
        end
      end
    end
    unless @codes.length < 2
      @codes.uniq!.sort!
    end
    
    last_entry = Hash.new
    prev_alert = Hash.new
    d_diff = 0
    p_diff = 0
    @alerts.each do |a|
      a.maint_codes.each do |sc|
        unless last_entry[sc.code].nil?
          prev_alert = last_entry[sc.code]
          d_diff = a.alert_date.to_i - prev_alert.alert_date.to_i
          unless (a.sheet_count.nil? or prev_alert.sheet_count.nil?)
            p_diff = (a.sheet_count.bw + a.sheet_count.color) - (prev_alert.sheet_count.bw + prev_alert.sheet_count.color)
          else
            p_diff = '*'
          end
          if (@data[a.alert_date].nil?)
            @data[a.alert_date] = {sc.code => {'d_date' => d_diff, 'd_page' => p_diff}}
          else
            @data[a.alert_date][sc.code] = {'d_date' => d_diff, 'd_page' => p_diff}
          end
        else
          if (@data[a.alert_date].nil?)
            @data[a.alert_date] = {sc.code => {'d_date' => '*', 'd_page' => '*'}}
          else
            @data[a.alert_date][sc.code] = {'d_date' => '*', 'd_page' => '*'}
          end
        end
        last_entry[sc.code] = a
      end
    end
    @title = "Detailed Maintenance Request Analysis for #{@dev.name}"
    render :template => 'report/history.html.erb'
    
  end
  
  def drum_dev_age
    @mc_bydev = Hash.new
    @devs = Device.order(:name)
    @devs.each do |d|
      mc = MaintCounter.joins(:alert).where("alerts.device_id = #{d.id}").order(:alert_date).last
      unless mc.nil?
        @mc_bydev[d.id] = mc
      end
    end
  end
  
  # Toner history for one device. Access as /report/:id/toner_history?days=N  
  def toner_history
    if (params.nil?)
      # should show an error message
    else
      @dev = Device.find params[:id]
      where_array = ["(alert_msg regexp 'toner supply is low') and device_id = ?", @dev.id]
      unless (params[:days].nil? or params[:days].empty?)
        @days = params[:days]
        where_array[0] += " and alert_date > date_sub(now(),interval ? day)"
        where_array << @days
      end
      @alerts = Alert.where(where_array).joins(:toner_codes).group('date(alert_date)', 'toner_codes.colour').count
      
      @toner_low = Hash.new
      # @toner_low's structure is:
      # {alert_date.to_date => {
      #                          colour => {'date_diff' => d, 'page_diff' => p, 'type' => 'toner_low'},
      #                          ...
      #                        }
      # }
      
      last_entry = Hash.new
      where_array << '' # just a couple of placeholders
      where_array << ''
      date_diff = 0
      where_array[0] = "(alert_msg regexp 'toner supply is low') and device_id = ? and toner_codes.colour = ? and date(alert_date) = ?"
      @alerts.each do |key,val|
        where_array[-1] = key[0]
        where_array[-2] = key[1]
        a = Alert.where(where_array).order('alert_date').joins(:toner_codes).first
        
        unless (last_entry[key[1]].nil?)
          prev_alert = last_entry[key[1]]
          date_diff = ((a.alert_date - prev_alert.alert_date)/86400).to_i
          if (date_diff > 10)
            if (@toner_low[key[0]].nil?)
              @toner_low[key[0]] = {key[1] => {'date_diff' => date_diff}}
            else
              @toner_low[key[0]][key[1]] = {'date_diff' => date_diff}
            end
            unless (prev_alert.sheet_count.nil? or a.sheet_count.nil?)
              if (key[1] == 'Bk')
                @toner_low[key[0]][key[1]]['page_diff'] = a.sheet_count.bw - prev_alert.sheet_count.bw
              else
                @toner_low[key[0]][key[1]]['page_diff'] = a.sheet_count.color - prev_alert.sheet_count.color
              end
            end
          end
        else
          if @toner_low[key[0]].nil?
            @toner_low[key[0]] = {key[1] => {'date_diff' => '*', 'page_diff' => '*'}}
          else
            @toner_low[key[0]][key[1]] = {'date_diff' => '*', 'page_diff' => '*'}
          end
        end
        last_entry[key[1]] = a 
      end
      @toner_low.each_value do |toners|
        toners['type'] = 'toner_low'
      end
    
      where_array = ["(alert_msg regexp 'add toner') and device_id = ?", @dev.id]
      unless @days.nil? or @days.empty?
        where_array[0] += " and alert_date > date_sub(now(),interval ? day)"
        where_array << @days
      end
      @alerts = Alert.where(where_array).joins(:toner_codes).group('date(alert_date)', 'toner_codes.colour').count
      
      @toner_out = Hash.new
      last_entry = Hash.new
      where_array << '' # just a couple of placeholders
      where_array << ''
      date_diff = 0
      where_array[0] = "(alert_msg regexp 'add toner') and device_id = ? and toner_codes.colour = ? and date(alert_date) = ?"

      @alerts.each do |key,val|
        where_array[-1] = key[0]
        where_array[-2] = key[1]
        a = Alert.where(where_array).order('alert_date').joins(:toner_codes).first
        unless (last_entry[key[1]].nil?)
          prev_alert = last_entry[key[1]]
          date_diff = ((a.alert_date - prev_alert.alert_date)/86400).to_i
          if (date_diff > 10)
            if (@toner_out[key[0]].nil?)
              @toner_out[key[0]] = {key[1] => {'date_diff' => date_diff}}
            else
              @toner_out[key[0]][key[1]] = {'date_diff' => date_diff}
            end
            unless (prev_alert.sheet_count.nil? or a.sheet_count.nil?)
              if (key[1] == 'Bk')
                @toner_out[key[0]][key[1]]['page_diff'] = a.sheet_count.bw - prev_alert.sheet_count.bw
              else
                @toner_out[key[0]][key[1]]['page_diff'] = a.sheet_count.color - prev_alert.sheet_count.color
              end
            end
          end
        else
          if @toner_out[key[0]].nil?
            @toner_out[key[0]] = {key[1] => {'date_diff' => '*', 'page_diff' => '*'}}
          else
            @toner_out[key[0]][key[1]] = {'date_diff' => '*', 'page_diff' => '*'}
          end
        end
        last_entry[key[1]] = a 
      end
      @toner_out.each_value do |toners|
        toners['type'] = 'toner_out'
      end
      # Sort the combined @toner_out and @toner_low results
      date_list = (@toner_out.keys + @toner_low.keys).sort.uniq
      @toner_alerts = []
      date_list.each do |d|
        @toner_alerts << {d => @toner_low[d]} unless @toner_low[d].nil?
        @toner_alerts << {d => @toner_out[d]} unless @toner_out[d].nil?
      end
    end
    
  end
  
    
  # Show list of devices that have usage(s) that exceed their rated volume
  def volume
    where_array = Array.new
    conditions_array = ['place holder']
    @days = 30
    if (not params[:name_q].nil? and not params[:name_q].empty?)
      @name_q = params[:name_q]
      where_array << @name_q.where('devices.name')
      conditions_array << @name_q.condition
    end
    if (not params[:client].nil? and not params[:client][:name].empty?)
      @client = Client.new
      @client.name = params[:client][:name]
      where_array << @client.name.where('clients.name')
      conditions_array << @client.name.condition
    end
    unless (params[:days].nil?)
      @days = params[:days].to_i
    end
    unless( where_array.empty? )
      conditions_array[0] = where_array.join(' and ')
    else
      conditions_array = []
    end
    @all_devices = Counter.group(:device_id).order('devices.name').select(:device_id).where(conditions_array).joins(:device => :client)
    @devices = Array.new
    @first = Hash.new
    @last = Hash.new
    @oldbw = Hash.new
    @newbw = Hash.new
    @oldc = Hash.new
    @newc = Hash.new
    @healthbw = Hash.new
    @healthc = Hash.new
    @bw_ratio = Hash.new
    @c_ratio = Hash.new
    
    @all_devices.each do |d|
      @last[d.device_id] = Counter.latest(d.device_id)
      @newc[d.device_id] = @last[d.device_id].totalprint1c.to_i + @last[d.device_id].totalprint2c.to_i + @last[d.device_id].totalprintc.to_i
      @newbw[d.device_id] = @last[d.device_id].totalprintbw.to_i
      
      first_date = @last[d.device_id].status_date - @days*86400
      @first[d.device_id] = Counter.earliest_or_before(first_date,d.device_id)
      unless @first[d.device_id].nil?
        @oldc[d.device_id] = @first[d.device_id].totalprint1c.to_i + @first[d.device_id].totalprint2c.to_i + @first[d.device_id].totalprintc.to_i
        @oldbw[d.device_id] = @first[d.device_id].totalprintbw
        totalbw = @newbw[d.device_id] - @oldbw[d.device_id]
        totalc  = @newc[d.device_id]  - @oldc[d.device_id]
        # @last and @first may not be exactly 30 days apart so must account for the actual number of days.
        days = (@last[d.device_id].status_date - @first[d.device_id].status_date) / 86400.0
        @bw_ratio[d.device_id] = (totalbw * 30 / days) / d.device.print_volume.ave_bw
        if (@bw_ratio[d.device_id] > 1.5)
          @healthbw[d.device_id] = 'red'
        elsif (@bw_ratio[d.device_id] <= 1.5 and @bw_ratio[d.device_id] > 1)
          @healthbw[d.device_id] = 'yellow'
        end
        unless (d.device.print_volume.ave_c.nil? or d.device.print_volume.ave_c == 0)
          @c_ratio[d.device_id] = (totalc * 30 / days) / d.device.print_volume.ave_c
          if (@c_ratio[d.device_id] > 1.5)
            @healthc[d.device_id] = 'red'
          elsif (@c_ratio[d.device_id] <= 1.5 and @c_ratio[d.device_id] > 1)
            @healthc[d.device_id] = 'yellow'
          end
        end
      else
        @oldc[d.device_id] = 0
        @oldbw[d.device_id] = 0
      end
      if ((not @bw_ratio[d.device_id].nil? and @bw_ratio[d.device_id] > 1) or (not @c_ratio[d.device_id].nil? and @c_ratio[d.device_id] > 1))
        @devices << d
      end
    end
#     render 'counters/index'
  end

  # Produce chart of number of daily "Misfeed", "Maintenance Request" and
  # "Call for Service" alerts for a single device over the past 30-, 60-, or 90-days.
  # Actually the number of days can be arbitrary but I only provide selection
  # options for those three.
  def alerts_graph
    @days = 30
    if (params.nil? or params[:device].nil? or params[:device][:id].empty?)
      @chart = LazyHighCharts::HighChart.new('graph') do |f|
        f.title(:text => "No device selected")
      end
    else
      if (not params[:days].nil? and not params[:days].empty?)
        @days = params[:days].to_i
      end
      @device_id = params[:device][:id]
      @device = Device.find @device_id
      misfeed_alerts = Alert.where(["device_id=? and alert_msg regexp 'misfeed' and alert_date > date_sub(curdate(), interval ? day)",@device_id,@days]).group('date(alert_date)').count
      maint_alerts = Alert.where(["device_id=? and alert_msg regexp 'maintenance' and alert_date > date_sub(curdate(), interval ? day)",@device_id,@days]).group('date(alert_date)').count
      service_alerts = Alert.where(["device_id=? and alert_msg regexp 'service' and alert_date > date_sub(curdate(), interval ? day)",@device_id,@days]).group('date(alert_date)').count
      misfeed_data = Hash.new
      maint_data = Hash.new
      service_data = Hash.new
      (@days.days.ago.to_date..Date.today).map do |date|
        misfeed_data[date] = misfeed_alerts[date].nil? ? 0 : misfeed_alerts[date]
        maint_data[date] = maint_alerts[date].nil? ? 0 : maint_alerts[date]
        service_data[date] = service_alerts[date].nil? ? 0 : service_alerts[date]
      end
      @chart = LazyHighCharts::HighChart.new('chart') do |f|
        f.type('scatter')
        f.title( {:text => "Alerts for #{@device.name}"} )
        f.xAxis( :type => 'datetime' )
        f.series( :type => 'line', :name => 'Misfeed', 
                  :pointInterval => 1.day,
                  :pointStart => @days.days.ago.to_date,
                  :data => misfeed_data.to_a )
        f.series( :type => 'line', :name => 'Maintenance Request', 
                  :pointInterval => 1.day,
                  :pointStart => @days.days.ago.to_date,
                  :data => maint_data.to_a )
        f.series( :type => 'line', :name => 'Call for Service', 
                  :pointInterval => 1.day,
                  :pointStart => @days.days.ago.to_date,
                  :data => service_data.to_a )
#         f.series( :name => 'test', :data => test_data )
      end
    end
  end

  # Produce chart of bw and colour (if available) page counts between readings.
  def device_volume_graph
    @days = 30
    if (params.nil? or params[:device].nil? or params[:device][:id].empty?)
      @chart = LazyHighCharts::HighChart.new('graph') do |f|
        f.title(:text => "No device selected")
      end
    else
      if (not params[:days].nil? and not params[:days].empty?)
        @days = params[:days].to_i
      end
      @device_id = params[:device][:id]
      @device = Device.find @device_id
      bw_vol = Hash.new
      color_vol = Hash.new
      alerts = Alert.where(["device_id=? and alert_date > date_sub(curdate(), interval ? day)",@device_id,@days]).group('date(alert_date)').each do |a|
        unless a.sheet_count.nil?
          bw_vol[a.alert_date.to_i] = a.sheet_count.bw
          color_vol[a.alert_date.to_i] = a.sheet_count.color
        end
      end
      @chart = LazyHighCharts::HighChart.new('chart') do |f|
        f.type('scatter')
        f.title( {:text => "Print volume for #{@device.name}"})
        f.xAxis( :labels => {:formatter => 'function(){return (new Date(this.value*1000)).toDateString();}'.js_code} )
        f.yAxis( [{:id => 0, :title => {:text => "Colour"}},{:id => 1, :opposite => true, :title => {:text => "Black and White"}}])
        f.tooltip( :formatter => 'function(){return("<span style=\"font-size: 10px\">" + (new Date(this.x*1000)).toDateString() + "</span><br /><span style=\"color:" + this.series.color + "\">" + this.series.name + ": " + this.y + "</span><br/>");}'.js_code)
        f.series(:type => 'line', :name => 'Colour',
#                  :pointInterval => 1.day,
#                  :pointStart => @days.days.ago.to_date,
                 :data => color_vol.to_a,
                 :yAxis => 0)
        f.series(:type => 'line', :name => 'Black and White',
                 #                  :pointInterval => 1.day,
                 #                  :pointStart => @days.days.ago.to_date,
                 :data => bw_vol.to_a,
                 :yAxis => 1)
      end
    end
  end
  
  # Produce chart of device drum stats over time
  
end
